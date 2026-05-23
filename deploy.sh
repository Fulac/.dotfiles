#!/usr/bin/env bash

# ============================================================================
# Dotfiles Deployer
# ============================================================================
#
# Purpose:
#   dotfiles リポジトリ内の設定ファイルを、各ツールが期待する標準的な
#   配置場所にシンボリックリンクで展開するスクリプト
#   XDG Base Directory 仕様に従い、$HOME/.config 配下と $HOME 直下に
#   適切に振り分ける
#
# Deployment modes:
#   - client : デスクトップ環境向け (alacritty を含む完全構成)
#   - server : headless 環境向け (alacritty 除外、Neovim は導入済みの場合のみ)
#   - uninstall : 全 symlink を削除して原状回復
#
# Target files:
#   - zsh設定         → ~/.zshrc                          (シンボリックリンク)
#   - Neovim設定      → ~/.config/nvim                    (ディレクトリリンク)
#   - Vim設定         → ~/.vim                            (ディレクトリリンク)
#   - Alacritty設定   → ~/.config/alacritty/alacritty.toml (client のみ)
#   - sheldon設定     → ~/.config/sheldon                 (ディレクトリリンク)
#
# Side effects:
#   - Neovim Python仮想環境 (~/.local/share/nvim/venv) の構築
#     └─ pynvim パッケージを uv 経由でインストール
#
# Usage:
#   ./deploy.sh              # client モード (デフォルト)
#   ./deploy.sh client       # client モード (明示)
#   ./deploy.sh --server     # server モード (headless環境用)
#   ./deploy.sh --uninstall  # 全 symlink を削除
#
# Maintenance notes:
#   - 新しいツールを追加する場合は deploy_client/deploy_server に deploy_link を追加
#   - 削除する場合は uninstall_all にも忘れずに remove_link を追加
#   - dotfiles のディレクトリ構造を変更した場合は DOTFILES_* 変数を更新
#   - dotfiles 内の設定ファイル配置: config/<tool>/<config_file>
#
# Prerequisites:
#   - bootstrap.sh を先に実行して各ツールがインストール済みであること
#     (zsh, sheldon, uv, neovim, etc.)
#
# ============================================================================

set -euo pipefail

# ============================================================================
# Color definitions (ANSI escape codes)
# ============================================================================
# 端末出力の視認性向上のためのカラー定義
# bootstrap.sh と同じカラースキームで統一
readonly RED='\033[1;31m'      # エラー
readonly YELLOW='\033[1;33m'   # 警告
readonly BLUE='\033[1;34m'     # 情報
readonly GREEN='\033[1;32m'    # 成功
readonly NC='\033[0m'          # リセット (No Color)

# ============================================================================
# Logging utilities
# ============================================================================

# 情報メッセージ (青色) - 通常の進捗報告
log()  { printf "${BLUE}==>${NC} %s\n" "$*"; }
# 警告メッセージ (黄色, stderr) - 処理は継続するが注意が必要
warn() { printf "${YELLOW}==>${NC} %s\n" "$*" >&2; }
# エラーメッセージ (赤色, stderr) - exit 1 で即時終了
err()  { printf "${RED}==>${NC} %s\n" "$*" >&2; exit 1; }
# 成功メッセージ (緑色) - 処理完了の確認
ok()   { printf "${GREEN}✓${NC} %s\n" "$*"; }

# ============================================================================
# Path variables
# ============================================================================
#
# DOTFILES_DIR: deploy.sh が置かれているディレクトリの絶対パス
#   - BASH_SOURCE[0] でスクリプト自身のパスを取得
#   - cd && pwd でシンボリックリンクや相対パスを解決した絶対パスに変換
#   - 結果として、どこから実行しても正しい dotfiles のルートを指す
#
# CONFIG_DIR: XDG_CONFIG_HOME のデフォルト値 (~/.config)
#   - 多くのツールが設定ファイルの配置場所として参照する
#
# DEPLOYMENT_MODE: 第1引数を取得 (デフォルトは "client")
#   - validate_mode 関数で正規化される
#
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${HOME}/.config"
DEPLOYMENT_MODE="${1:-client}"

# ============================================================================
# Dotfiles source paths
# ============================================================================
# dotfiles 内の設定ファイル配置場所を定義
# 新しいツールを追加する場合はここに変数を追加
#
# Directory structure:
#   ~/.dotfiles/
#   └── config/
#       ├── zsh/        (zshrc, sheldon/, starship.toml, etc.)
#       ├── nvim/       (init.lua, lua/, after/)
#       ├── vim/        (vimrc, colors/)
#       └── alacritty/  (alacritty.toml)
#
DOTFILES_ZSH="${DOTFILES_DIR}/config/zsh"
DOTFILES_NVIM="${DOTFILES_DIR}/config/nvim"
DOTFILES_VIM="${DOTFILES_DIR}/config/vim"
DOTFILES_ALACRITTY="${DOTFILES_DIR}/config/alacritty"

# ============================================================================
# Helper functions
# ============================================================================

# ----------------------------------------------------------------------------
# validate_mode: コマンドライン引数を検証し、DEPLOYMENT_MODE を正規化
# ----------------------------------------------------------------------------
#
# 機能:
#   - 複数の表記 (client, --client, -c など) を受け付け
#   - 不正な値の場合はエラーで即時終了
#   - 正規化後の値: "client", "server", "uninstall" のいずれか
#
# Maintenance note:
#   新しいモードを追加する場合はここに case 文を追加し、
#   main() の case 文にも対応する処理を追加すること
#
validate_mode() {
  case "$DEPLOYMENT_MODE" in
    client | --client | -c)
      DEPLOYMENT_MODE="client"
      ;;
    server | --server | -s)
      DEPLOYMENT_MODE="server"
      ;;
    uninstall | --uninstall)
      DEPLOYMENT_MODE="uninstall"
      ;;
    *)
      err "Invalid mode: $DEPLOYMENT_MODE"$'\n'"Usage: $0 [client|server|--uninstall]"
      ;;
  esac
}

# ----------------------------------------------------------------------------
# deploy_link: シンボリックリンクを安全に作成
# ----------------------------------------------------------------------------
#
# Arguments:
#   $1 (src)  : リンク元 (dotfiles 内の設定ファイル/ディレクトリ)
#   $2 (dst)  : リンク先 ($HOME 配下の標準配置場所)
#   $3 (desc) : ログ表示用の説明文 (例: "zshrc", "Neovim config")
#
# 処理フロー:
#   1. ソース存在確認: 存在しなければ警告して return 1 (処理続行)
#   2. 親ディレクトリ作成: dst の親が無ければ mkdir -p
#   3. 既存ファイル削除: dst に何かあれば rm -rf で削除 (上書き準備)
#   4. シンボリックリンク作成: ln -sf で src → dst のリンクを張る
#
# Safety considerations:
#   - rm -rf を使うため、$dst の値には十分注意 (バグると致命的)
#   - ln -sf の -f オプションは既存リンクを強制上書きするが、一般ファイルでは効かないため、事前に rm -rf している
#   - 親ディレクトリの作成は再帰的 (-p) なので深いパスでも安全
#
# Maintenance note:
#   既存の通常ファイル (シンボリックリンクでない) があった場合、このスクリプトは無条件で上書きする。
#   バックアップが必要なら呼び出し側で対応すること。
#
deploy_link() {
  local src="$1"
  local dst="$2"
  local desc="$3"

  # ソースが存在するか確認 (存在しなければスキップ)
  # -e はファイル/ディレクトリ存在確認、-L はシンボリックリンク確認
  if [[ ! -e "$src" && ! -L "$src" ]]; then
    warn "Source not found: $src (skipping $desc)"
    return 1
  fi

  # 親ディレクトリを作成 (例: ~/.config/alacritty/ が無ければ作る)
  local dst_parent
  dst_parent="$(dirname "$dst")"
  if [[ ! -d "$dst_parent" ]]; then
    mkdir -p "$dst_parent"
    log "Created directory: $dst_parent"
  fi

  # 既存ファイル・リンクを削除 (冪等性のため)
  # 通常ファイル、ディレクトリ、シンボリックリンクのいずれも削除可能
  if [[ -e "$dst" || -L "$dst" ]]; then
    rm -rf "$dst"
  fi

  # シンボリックリンク作成
  # -s: シンボリックリンク
  # -f: 強制 (既存リンクを上書き、ただし通常ファイルには効かない)
  ln -sf "$src" "$dst"
  ok "Deployed $desc"
}

# ----------------------------------------------------------------------------
# remove_link: シンボリックリンクまたはファイルを削除
# ----------------------------------------------------------------------------
#
# Arguments:
#   $1 (dst) : 削除対象のパス
#
# 処理内容:
#   - リンクまたはファイルが存在する場合のみ削除
#   - 存在しなければ何もせず終了 (エラーにしない)
#
# Maintenance note:
#   uninstall_all 関数からのみ呼ばれる
#   削除対象のパスはハードコードされているため、誤削除リスクは低い
#
remove_link() {
  local dst="$1"

  if [[ -L "$dst" || -e "$dst" ]]; then
    rm -rf "$dst"
    ok "Removed: $dst"
  fi
}

# ----------------------------------------------------------------------------
# has_command: コマンドの存在確認
# ----------------------------------------------------------------------------
#
# Arguments:
#   $1 : コマンド名
#
# Returns:
#   0: コマンドが存在
#   1: コマンドが存在しない
#
has_command() {
  command -v "$1" >/dev/null 2>&1
}

# ----------------------------------------------------------------------------
# setup_nvim_python_env: Neovim 用 Python 仮想環境の構築
# ----------------------------------------------------------------------------
#
# 目的:
#   Neovim から Python プラグイン (pynvim) を利用可能にするため、
#   専用の Python 仮想環境を ~/.local/share/nvim/venv に構築する
#
# 配置先:
#   ~/.local/share/nvim/venv/           (venv のルート)
#   ~/.local/share/nvim/venv/bin/python (Python 実行ファイル)
#
# 処理フロー:
#   1. 依存コマンド確認 (nvim, python, uv)
#      └─ いずれか欠けていればスキップ (警告)
#   2. 既存環境チェック
#      └─ venv 存在 AND pynvim importable → スキップ
#   3. 不完全な venv の削除 (前回失敗時の残骸対応)
#   4. uv venv で新規構築
#   5. pip install pynvim で pynvim を導入
#
# Neovim 側の連携:
#   zshrc 内の以下のエイリアスで連携:
#     alias nvpip="UV_PYTHON=${HOME}/.local/share/nvim/venv/bin/python uv pip"
#   init.lua 等で g:python3_host_prog にこのパスを指定することで、
#   Neovim が pynvim を見つけられるようになる
#
# Maintenance note:
#   - pynvim のバージョン固定が必要になった場合は pip install pynvim==X.Y.Z で指定
#   - Python venv の場所を変更する場合は venv_path 変数を更新
#   - 他のパッケージを追加する場合は uv pip install で追記
#
setup_nvim_python_env() {
  local venv_path="${HOME}/.local/share/nvim/venv"
  local venv_python="${venv_path}/bin/python"

  log "Checking Neovim Python environment..."

  # 依存コマンドの確認 (3つすべて必要)
  if ! has_command nvim || ! has_command python || ! has_command uv; then
    warn "nvim, python, or uv is not installed. Skipping Python env setup."
    return 0
  fi

  # 既に完全に構築されているか確認
  # venv の Python が実行可能 AND pynvim がインポート可能なら何もしない
  if [[ -x "$venv_python" ]] && "$venv_python" -c "import pynvim" >/dev/null 2>&1; then
    ok "Neovim Python environment already configured"
    return 0
  fi

  # 既存の不完全な環境を削除
  # 前回のインストール失敗で中途半端な venv が残っているケースに対応
  if [[ -d "$venv_path" ]]; then
    log "Cleaning up incomplete venv at $venv_path"
    rm -rf "$venv_path"
  fi

  # 新規構築
  log "Building Neovim Python environment..."
  mkdir -p "$(dirname "$venv_path")"

  # uv venv: 高速な venv 作成 (uv が pip より大幅に高速)
  uv venv "$venv_path"

  # pip install pynvim: Neovim 用 Python ブリッジ
  # 出力は抑制 (>/dev/null 2>&1) して、成功時のメッセージをシンプルに
  "$venv_python" -m pip install pynvim >/dev/null 2>&1
  ok "Neovim Python environment ready"
}

# ============================================================================
# Deployment functions
# ============================================================================

# ----------------------------------------------------------------------------
# deploy_client: クライアント (デスクトップ) 環境向けのデプロイ
# ----------------------------------------------------------------------------
#
# 対象環境:
#   - GUI を持つデスクトップ Linux
#   - Alacritty などの GPU ターミナルを使用
#   - Neovim をフル活用 (Python venv も構築)
#
# Deploy targets:
#   1. zsh設定         → ~/.zshrc
#   2. Neovim設定      → ~/.config/nvim
#   3. Neovim Python venv構築
#   4. Vim設定         → ~/.vim
#   5. Alacritty設定   → ~/.config/alacritty/alacritty.toml
#   6. sheldon設定     → ~/.config/sheldon (存在する場合のみ)
#
# Maintenance note:
#   - 新しい GUI ツールを追加する場合はここに deploy_link を追加
#   - deploy_server とほぼ同じ処理だが、Alacritty の扱いだけが異なる
#
deploy_client() {
  log "Starting deployment [CLIENT MODE]..."

  # zsh
  # zshrc は HOME 直下に配置 (zsh 起動時に自動読み込み)
  deploy_link "${DOTFILES_ZSH}/zshrc" "${HOME}/.zshrc" "zshrc"

  # Neovim (client では必須)
  # ディレクトリ全体を symlink でリンク (init.lua, lua/, after/ など)
  deploy_link "${DOTFILES_NVIM}" "${CONFIG_DIR}/nvim" "Neovim config"
  # Neovim 用の Python 仮想環境を構築
  setup_nvim_python_env

  # Vim
  # Vim は XDG 非準拠で ~/.vim を見るため、ここに配置
  deploy_link "${DOTFILES_VIM}" "${HOME}/.vim" "Vim config"

  # Alacritty (client のみ、headless では不要)
  # ファイル単位の symlink (TOML ファイル1つだけ)
  deploy_link "${DOTFILES_ALACRITTY}/alacritty.toml" "${CONFIG_DIR}/alacritty/alacritty.toml" "Alacritty config"

  # sheldon (プラグインマネージャ設定)
  # 配置場所が dotfiles 構成によって異なる場合があるため、存在チェック付き
  if [[ -d "${DOTFILES_ZSH}/sheldon" ]]; then
    deploy_link "${DOTFILES_ZSH}/sheldon" "${CONFIG_DIR}/sheldon" "sheldon config"
  fi

  ok "Client deployment complete"
}

# ----------------------------------------------------------------------------
# deploy_server: サーバー (headless) 環境向けのデプロイ
# ----------------------------------------------------------------------------
#
# 対象環境:
#   - GUI なし (headless) の Linux サーバー
#   - SSH 経由でアクセス
#   - Alacritty は不要
#
# client モードとの差異:
#   - Alacritty 設定はスキップ
#   - Neovim はインストールされている場合のみデプロイ
#
# Maintenance note:
#   - サーバー専用の設定 (例: tmux) を追加する場合はここに追記
#   - 共通設定 (zsh, vim, sheldon) は client/server 両方で必須
#
deploy_server() {
  log "Starting deployment [SERVER MODE]..."

  # zsh
  deploy_link "${DOTFILES_ZSH}/zshrc" "${HOME}/.zshrc" "zshrc"

  # Vim
  deploy_link "${DOTFILES_VIM}" "${HOME}/.vim" "Vim config"

  # Neovim (インストールされている場合のみ)
  if has_command nvim; then
    deploy_link "${DOTFILES_NVIM}" "${CONFIG_DIR}/nvim" "Neovim config"
    setup_nvim_python_env
  else
    log "Neovim not installed. Skipping Neovim configuration."
  fi

  # sheldon (プラグインマネージャ設定)
  if [[ -d "${DOTFILES_ZSH}/sheldon" ]]; then
    deploy_link "${DOTFILES_ZSH}/sheldon" "${CONFIG_DIR}/sheldon" "sheldon config"
  fi

  ok "Server deployment complete"
}

# ----------------------------------------------------------------------------
# uninstall_all: 全 symlink を削除して原状回復
# ----------------------------------------------------------------------------
#
# 目的:
#   deploy_client/deploy_server で作成された全ての symlink を削除する
#   主にデプロイ失敗時のリカバリや、dotfiles の切り替え時に使用
#
# 削除対象:
#   - ~/.zshrc
#   - ~/.config/nvim
#   - ~/.vim
#   - ~/.config/alacritty/alacritty.toml
#   - ~/.config/sheldon
#
# 削除しないもの:
#   - ~/.local/share/nvim/venv  (Python仮想環境、ユーザーデータ扱い)
#   - 親ディレクトリ自体        (~/.config/nvim を削除しても ~/.config は残す)
#
# Maintenance note:
#   - deploy_client/deploy_server に新規 deploy_link を追加した場合は、
#     ここにも対応する remove_link を必ず追加すること (忘れると残骸が残る)
#
uninstall_all() {
  log "Starting uninstall..."

  remove_link "${HOME}/.zshrc"
  remove_link "${CONFIG_DIR}/nvim"
  remove_link "${HOME}/.vim"
  remove_link "${CONFIG_DIR}/alacritty/alacritty.toml"
  remove_link "${CONFIG_DIR}/sheldon"

  ok "Uninstall complete"
}

# ============================================================================
# Main entry point
# ============================================================================
#
# 処理フロー:
#   1. validate_mode: 引数を検証して DEPLOYMENT_MODE を正規化
#   2. case 分岐で各モードの関数を呼び出し
#   3. 完了メッセージを表示
#
# Maintenance note:
#   新しいモード (例: minimal モード) を追加する場合:
#     1. validate_mode に新モードの case を追加
#     2. 対応する deploy_minimal() 等の関数を実装
#     3. ここの case 文に呼び出しを追加
#
main() {
  # 引数の検証と正規化
  validate_mode

  # モードに応じた処理を実行
  case "$DEPLOYMENT_MODE" in
    client)
      deploy_client
      ;;
    server)
      deploy_server
      ;;
    uninstall)
      uninstall_all
      ;;
  esac

  echo
  log "Deployment finished successfully"
}

# スクリプト実行時のエントリポイント
# "$@" でコマンドライン引数をそのまま main に渡す
main "$@"
