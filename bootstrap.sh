#!/usr/bin/env bash
#
# ============================================================================
# Multi-distro dotfiles bootstrap script
# ============================================================================
#
# Purpose:
#   Clean Linux install から必要なパッケージを全自動でインストールするスクリプト
#   ディストロを自動検出し、適切なパッケージマネージャと公式インストール
#   スクリプトを組み合わせて、シェル環境一式を構築する
#
# Supported distros:
#   - Arch family   (cachyos, arch, manjaro, endeavouros, garuda)
#   - Fedora family (fedora, rhel, rocky, almalinux)
#   - Debian family (ubuntu, debian, linuxmint, pop)
#
# Default behavior:
#   全パッケージをインストール対象とする
#   特定ツールを除外したい場合は --without-* オプションを指定
#
# Optional tools (除外可能):
#   - alacritty : GPU高速ターミナル (headless環境では不要)
#   - starship  : シェルプロンプト
#   - neovim    : Lua制御のモダンエディタ
#     └─ neovim導入時は nodejs, npm, tree-sitter-cli も同時に導入
#
# Usage:
#   ./bootstrap.sh                       # install everything (default)
#   ./bootstrap.sh --without-alacritty   # exclude alacritty (headless/server)
#   ./bootstrap.sh --without-starship    # exclude starship (use fallback prompt)
#   ./bootstrap.sh --without-neovim      # exclude neovim and its deps
#   ./bootstrap.sh --without-alacritty --without-neovim   # multiple exclusions
#   DRY_RUN=1 ./bootstrap.sh             # show commands without executing
#
# Maintenance notes:
#   - 新ツールを追加する場合は Phase 3 or Phase 5 のいずれかに追加
#   - ディストロ別パッケージ名が異なる場合は install_pkg の case に注意
#   - 公式スクリプトのURLは Astral/Starship/Sheldon/Zoxide の公式から確認
#
# ============================================================================

set -euo pipefail

# ============================================================================
# Color definitions (ANSI escape codes)
# ============================================================================
# 端末出力の視認性を上げるためのカラー定義
# log/warn/err/ok の各関数はこれらを使って色付きメッセージを出力する
readonly RED='\033[1;31m'      # エラー
readonly YELLOW='\033[1;33m'   # 警告
readonly BLUE='\033[1;34m'     # 情報
readonly GREEN='\033[1;32m'    # 成功
readonly NC='\033[0m'          # リセット (No Color)

# ============================================================================
# Utility functions
# ============================================================================

# 情報メッセージ (青色)
log()  { printf "${BLUE}==>${NC} %s\n" "$*"; }
# 警告メッセージ (黄色, stderr)
warn() { printf "${YELLOW}==>${NC} %s\n" "$*" >&2; }
# エラーメッセージ (赤色, stderr) - exit 1 で即時終了
err()  { printf "${RED}==>${NC} %s\n" "$*" >&2; exit 1; }
# 成功メッセージ (緑色)
ok()   { printf "${GREEN}✓${NC} %s\n" "$*"; }

# コマンド実行のラッパー
# DRY_RUN=1 のときは実行せずコマンドを表示するだけ (確認用)
run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    printf '   [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

# コマンドの存在確認
# `which` や `type` より移植性が高い
has() { command -v "$1" >/dev/null 2>&1; }

# ============================================================================
# Configuration (default: install everything)
# ============================================================================
# 各オプションツールの導入可否フラグ
# デフォルトは true (インストールする)
# コマンドライン引数 --without-* で個別に false に設定可能
INSTALL_ALACRITTY=true
INSTALL_STARSHIP=true
INSTALL_NEOVIM=true

# ============================================================================
# Command-line argument parsing
# ============================================================================
# --without-* オプションでオプションツールを除外
# --help で使い方表示
while (( $# > 0 )); do
  case "$1" in
    --without-alacritty)
      INSTALL_ALACRITTY=false
      ;;
    --without-starship)
      INSTALL_STARSHIP=false
      ;;
    --without-neovim)
      # neovim を除外する場合は nodejs/npm/tree-sitter-cli も連動して除外
      INSTALL_NEOVIM=false
      ;;
    -h | --help)
      cat <<EOF
Usage: $0 [OPTIONS]

By default, all packages are installed. Use options below to exclude specific tools.

Options:
  --without-alacritty   Skip alacritty installation (headless/server environments)
  --without-starship    Skip starship installation (use fallback prompt)
  --without-neovim      Skip neovim installation (also skips nodejs/npm/tree-sitter-cli)
  -h, --help            Show this help message

Environment:
  DRY_RUN=1             Show commands without executing them

Examples:
  $0                                       # install everything (default)
  $0 --without-alacritty                   # for server/headless environments
  $0 --without-alacritty --without-neovim  # minimal install
EOF
      exit 0
      ;;
    *)
      err "Unknown option: $1"$'\n'"Run '$0 --help' for usage."
      ;;
  esac
  shift
done

# ============================================================================
# Preflight checks
# ============================================================================
# スクリプト実行前の安全確認

# root 実行を禁止 (sudo は内部で呼び出す)
# 理由: ホームディレクトリ依存の処理が多いため、root だと意図しない場所にファイルが作成される
if [[ $EUID -eq 0 ]]; then
  err "Do not run as root. Use a regular user account."
fi

# /etc/os-release がない環境 (非systemd系) は非対応
if [[ ! -f /etc/os-release ]]; then
  err "/etc/os-release not found. Unsupported OS."
fi

# /etc/os-release を読み込み、ID, ID_LIKE, PRETTY_NAME などを変数として展開
# shellcheck disable=SC1091
. /etc/os-release

# ============================================================================
# Distro family detection
# ============================================================================
# ディストロを「family」単位で分類し後段のパッケージ管理を簡素化
#
# Maintenance note:
#   新ディストロ対応する場合は以下のいずれかに ID を追加:
#     - Arch系派生 (例: artix) → arch
#     - RHEL系派生 (例: nobara) → fedora
#     - Debian系派生 (例: kali) → debian
#   ID で見つからない場合は ID_LIKE で fallback 判定する
DISTRO_FAMILY=""
case "${ID:-}" in
  arch|cachyos|manjaro|endeavouros|garuda)
    DISTRO_FAMILY="arch" ;;
  fedora|rhel|centos|rocky|almalinux)
    DISTRO_FAMILY="fedora" ;;
  ubuntu|debian|linuxmint|pop)
    DISTRO_FAMILY="debian" ;;
  *)
    # 未知のディストロも ID_LIKE で派生関係を判定
    case "${ID_LIKE:-}" in
      *arch*)    DISTRO_FAMILY="arch" ;;
      *fedora*|*rhel*) DISTRO_FAMILY="fedora" ;;
      *debian*)  DISTRO_FAMILY="debian" ;;
      *) err "Unsupported distro: ${ID:-unknown}" ;;
    esac
    ;;
esac

log "Detected: ${PRETTY_NAME:-$ID} (family: ${DISTRO_FAMILY})"
echo

# ============================================================================
# Installation plan summary
# ============================================================================
# 実行前にユーザーへインストール計画を提示する
log "Installation plan:"
echo "  Required tools     : zsh, git, curl, sheldon, uv,"
echo "                       bat, ripgrep, fd, eza, zoxide, fzf,"
echo "                       python3, build tools"
echo "  Alacritty          : $([ "$INSTALL_ALACRITTY" == true ] && echo 'yes' || echo 'no (--without-alacritty)')"
echo "  Starship           : $([ "$INSTALL_STARSHIP" == true ] && echo 'yes' || echo 'no (--without-starship)')"
echo "  Neovim suite       : $([ "$INSTALL_NEOVIM" == true ] && echo 'yes (with nodejs, npm, tree-sitter-cli)' || echo 'no (--without-neovim)')"
echo

# ============================================================================
# Package manager abstraction
# ============================================================================
#
# install_pkg <pkg1> [pkg2 ...]
#
# 機能:
#   - 既にインストール済みパッケージは検出してスキップ
#   - インストール失敗時も処理を継続
#   - DRY_RUN モードに対応
#
# ディストロ別の挙動:
#   - Arch  : paru があれば優先、なければ pacman + sudo
#   - Fedora: dnf install
#   - Debian: apt-get install (事前に apt-get update)
#
# Maintenance note:
#   apt-get update は時間がかかるため、Phase 2 (build tools導入時) で1回だけ実行する設計にしている。
#   新規 install_pkg 呼び出し前に最新情報が必要な場合は明示的に update を追加すること。
#
install_pkg() {
  local pkgs=("$@")
  local to_install=()

  case "$DISTRO_FAMILY" in
    arch)
      # pacman -Qi: パッケージの詳細情報を取得 (インストール済みかチェック)
      for p in "${pkgs[@]}"; do
        if pacman -Qi "$p" >/dev/null 2>&1; then
          ok "$p: already installed (pacman)"
        else
          to_install+=("$p")
        fi
      done

      # 全てインストール済みの場合は何もせず終了
      if (( ${#to_install[@]} == 0 )); then
        return 0
      fi

      log "Installing: ${to_install[*]}"
      # paru は AUR にも対応、pacman は公式リポジトリのみ
      # --needed: 既に最新版があれば何もしない
      # --noconfirm: 確認プロンプトを抑制
      if has paru; then
        run paru -S --needed --noconfirm "${to_install[@]}" || {
          warn "Some packages failed to install via paru, but continuing..."
        }
      else
        run sudo pacman -S --needed --noconfirm "${to_install[@]}" || {
          warn "Some packages failed to install via pacman, but continuing..."
        }
      fi
      ;;

    fedora)
      # rpm -q: パッケージのインストール状況をクエリ
      for p in "${pkgs[@]}"; do
        if rpm -q "$p" >/dev/null 2>&1; then
          ok "$p: already installed (rpm)"
        else
          to_install+=("$p")
        fi
      done

      if (( ${#to_install[@]} == 0 )); then
        return 0
      fi

      log "Installing: ${to_install[*]}"
      # -y: 確認プロンプトを抑制
      run sudo dnf install -y "${to_install[@]}" || {
        warn "Some packages failed to install via dnf, but continuing..."
      }
      ;;

    debian)
      # dpkg -s: パッケージのステータス情報を取得
      for p in "${pkgs[@]}"; do
        if dpkg -s "$p" >/dev/null 2>&1; then
          ok "$p: already installed (dpkg)"
        else
          to_install+=("$p")
        fi
      done

      if (( ${#to_install[@]} == 0 )); then
        return 0
      fi

      log "Installing: ${to_install[*]}"
      # -y: 確認プロンプトを抑制
      run sudo apt-get install -y "${to_install[@]}" || {
        warn "Some packages failed to install via apt, but continuing..."
      }
      ;;
  esac
}

# ============================================================================
# Official script installers
# ============================================================================
#
# パッケージマネージャに無い、または古いツールを公式インストールスクリプト経由で導入する関数群
#
# 配置先: ~/.local/bin (sudo不要、ユーザーローカル)
# 共通フロー: コマンド存在確認 → curl 確認 → DL & install → 成功確認
#
# Maintenance note:
#   公式インストールURLは各ツールの最新ドキュメントを参照すること
#   - starship : https://starship.rs/install.sh
#   - uv       : https://astral.sh/uv/install.sh
#   - sheldon  : https://rossmacarthur.github.io/install/crate.sh
#   - zoxide   : https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh
#
# starship をインストール (シェルプロンプト)
install_starship_script() {
  if has starship; then
    ok "starship: already installed"
    return 0
  fi

  if ! has curl; then
    warn "curl not found. Skipping starship installation."
    return 1
  fi

  log "Installing starship via official script..."
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${PATH}"

  # --bin-dir で配置先を明示し、sudo を回避
  run sh -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$HOME/.local/bin"' || {
    warn "starship installation failed, but continuing..."
    return 1
  }
  ok "starship installed"
}

# uv をインストール (Python パッケージマネージャ)
install_uv_script() {
  if has uv; then
    ok "uv: already installed"
    return 0
  fi

  if ! has curl; then
    warn "curl not found. Skipping uv installation."
    return 1
  fi

  log "Installing uv via official script..."
  # uv は ~/.cargo/bin にインストールされる場合があるためPATHを追加
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"

  run sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh' || {
    warn "uv installation failed, but continuing..."
    return 1
  }
  ok "uv installed"
}

# sheldon をインストール (zsh プラグインマネージャ)
# 高速化のため cargo-binstall を優先、失敗時は upstream script にフォールバック
install_sheldon_script() {
  if has sheldon; then
    ok "sheldon: already installed"
    return 0
  fi

  if ! has curl; then
    warn "curl not found. Skipping sheldon installation."
    return 1
  fi

  log "Installing sheldon..."
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"

  # 第1選択: cargo-binstall (事前ビルド済みバイナリをDL、高速)
  if has cargo-binstall; then
    log "Using cargo-binstall (faster, prebuilt binary)..."
    run cargo binstall -y sheldon && {
      ok "sheldon installed"
      return 0
    }
    warn "cargo-binstall failed, falling back to upstream installer..."
  fi

  # 第2選択: sheldon 作者の汎用インストールスクリプト
  log "Using upstream installer..."
  run sh -c 'curl --proto "=https" --tlsv1.2 -LsSf https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"' || {
    warn "sheldon installation failed, but continuing..."
    return 1
  }
  ok "sheldon installed"
}

# zoxide をインストール (学習型 cd 代替)
install_zoxide_script() {
  if has zoxide; then
    ok "zoxide: already installed"
    return 0
  fi

  if ! has curl; then
    warn "curl not found. Skipping zoxide installation."
    return 1
  fi

  log "Installing zoxide via official script..."
  mkdir -p "${HOME}/.local/bin"
  export PATH="${HOME}/.local/bin:${PATH}"

  run sh -c 'curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh' || {
    warn "zoxide installation failed, but continuing..."
    return 1
  }
  ok "zoxide installed"
}

# ============================================================================
# tree-sitter-cli installer (npm経由)
# ============================================================================
#
# tree-sitter-cli は Neovim の nvim-treesitter プラグインで使用される
# パーサのビルドや手動更新に必要
# Arch では公式リポジトリで提供されるが、他ディストロでは npm 経由でインストール
#
# Maintenance note:
#   - npm グローバルインストールは ~/.npm-global 等の設定がない場合、
#     sudo が必要になる場合がある
#   - 推奨: ~/.npmrc に `prefix=${HOME}/.npm-global` を設定し、
#     ~/.npm-global/bin を PATH に追加する
#   - npm が無い (= neovim を入れない) 場合はスキップ
#
install_tree_sitter_cli() {
  if has tree-sitter; then
    ok "tree-sitter-cli: already installed"
    return 0
  fi

  if ! has npm; then
    warn "npm not found. Skipping tree-sitter-cli installation."
    return 1
  fi

  log "Installing tree-sitter-cli system-wide (requires sudo)..."

  # npm のグローバルインストールはデフォルトで /usr/local/lib/node_modules
  # 実行可能ファイルは /usr/local/bin/tree-sitter にシンボリックリンクされる
  # sudo が必要な点はトレードオフ (ホームディレクトリを汚さない代償)
  run sudo npm install -g tree-sitter-cli || {
    warn "tree-sitter-cli installation failed, but continuing..."
    return 1
  }
  ok "tree-sitter-cli installed"
}

# ============================================================================
# Main bootstrap flow
# ============================================================================
#
# インストール処理を 6 phase に分けて実行
# 各 phase は独立しており、途中で失敗しても可能な限り後続を実行する
#
# Phase 1: Base packages       (zsh, git, curl)
# Phase 2: Build tools         (gcc, make, base-devel など)
# Phase 3: Modern CLI tools    (bat, ripgrep, fd, eza, fzf)
# Phase 4: Python toolchain    (python3, uv は Phase 6 で導入)
# Phase 5: Distro-specific     (sheldon, starship, alacritty, neovim, etc.)
# Phase 6: Official scripts    (Phase 5 でカバーできなかったツール)
#

main() {
  log "Starting bootstrap..."
  echo

  # ----------------------------------------------------------------
  # Phase 1: Base packages (required for all subsequent phases)
  # ----------------------------------------------------------------
  # zsh: メインシェル
  # git: dotfiles リポジトリ操作
  # curl: 公式インストールスクリプトのダウンロード
  log "Phase 1/6: Base packages (zsh, git, curl)"
  install_pkg zsh git curl
  echo

  # ----------------------------------------------------------------
  # Phase 2: Build tools
  # ----------------------------------------------------------------
  # 一部のツール (cargo, npm, etc.) はビルドに gcc/make を必要とする
  # apt-get update もここで実行 (Debian系のキャッシュ更新)
  log "Phase 2/6: Build tools"
  case "$DISTRO_FAMILY" in
    arch)
      # base-devel: gcc, make, binutils などをまとめて提供するメタパッケージ
      install_pkg base-devel
      ;;
    fedora)
      # Fedora には base-devel に相当するメタパッケージがあるが、
      # dnf groupinstall は冪等性に難があるため個別指定
      install_pkg gcc make
      ;;
    debian)
      # apt-get update を 1回だけ実行
      # 失敗してもパッケージ情報のキャッシュが古いだけで実害は少ない
      run sudo apt-get update -qq || warn "apt update failed, continuing..."
      install_pkg build-essential
      ;;
  esac
  echo

  # ----------------------------------------------------------------
  # Phase 3: Modern CLI tools (required, all distros)
  # ----------------------------------------------------------------
  # bat       : cat のリッチ版 (シンタックスハイライト, ページャ)
  # ripgrep   : grep の高速版 (.gitignore尊重, 並列処理)
  # fd        : find の使いやすい版
  # eza       : ls のモダン版 (アイコン, git連携, ツリー表示)
  # fzf       : ファジーファインダ (zsh統合で履歴検索が劇的改善)
  #
  # Maintenance note:
  #   Debian/Fedora では fd のパッケージ名が fd-find であることに注意
  #   (コマンド名は fdfind になるため、zshrc でエイリアスを設定)
  log "Phase 3/6: Modern CLI tools (bat, ripgrep, fd, eza, fzf)"
  case "$DISTRO_FAMILY" in
    arch)
      install_pkg bat ripgrep fd eza fzf
      ;;
    fedora)
      install_pkg bat ripgrep fd-find eza fzf
      ;;
    debian)
      install_pkg bat ripgrep fd-find eza fzf
      ;;
  esac
  echo

  # ----------------------------------------------------------------
  # Phase 4: Python toolchain
  # ----------------------------------------------------------------
  # python: Neovim Python venv の構築や各種スクリプトに必要
  # uv は Phase 6 で公式スクリプト経由で導入
  log "Phase 4/6: Python toolchain"
  case "$DISTRO_FAMILY" in
    arch)
      # Arch では python が 3系のデフォルト
      install_pkg python
      ;;
    fedora|debian)
      # Fedora/Debian では python3 を明示的に指定
      install_pkg python3
      ;;
  esac
  echo

  # ----------------------------------------------------------------
  # Phase 5: Distro-specific package manager installs
  # ----------------------------------------------------------------
  # ディストロのパッケージマネージャで提供されるツールを優先的に導入
  # 提供されないツールは Phase 6 の公式スクリプトで導入
  log "Phase 5/6: Distro-specific tool installs"
  case "$DISTRO_FAMILY" in
    arch)
      # Arch では基本的に全てのツールがリポジトリ/AURで提供される
      install_pkg sheldon uv zoxide

      if [[ "$INSTALL_STARSHIP" == true ]]; then
        install_pkg starship
      fi
      if [[ "$INSTALL_ALACRITTY" == true ]]; then
        install_pkg alacritty
      fi
      if [[ "$INSTALL_NEOVIM" == true ]]; then
        # neovim関連: エディタ本体 + プラグイン依存ツール
        # - nodejs/npm    : LSP server や言語ツールのインストール先
        # - tree-sitter   : nvim-treesitter のパーサビルド用 (Archは公式提供)
        install_pkg neovim nodejs npm tree-sitter
      fi
      ;;

    fedora)
      # Fedora は starship/alacritty/neovim/nodejs が dnf にある
      # sheldon, uv, zoxide は dnf にないため Phase 6 で導入
      if [[ "$INSTALL_STARSHIP" == true ]]; then
        install_pkg starship
      fi
      if [[ "$INSTALL_ALACRITTY" == true ]]; then
        install_pkg alacritty
      fi
      if [[ "$INSTALL_NEOVIM" == true ]]; then
        # Fedora: tree-sitter-cli は npm 経由で導入 (Phase 6相当)
        install_pkg neovim nodejs npm
      fi
      ;;

    debian)
      # Debian は apt 提供のものを優先
      # apt-cache show でリポジトリ提供状況を確認してから install_pkg を呼ぶ

      # zoxide: Ubuntu 22.10+, Debian 12+ で提供
      if apt-cache show zoxide >/dev/null 2>&1; then
        install_pkg zoxide
      fi

      # alacritty: Ubuntu 22.04+ で提供 (Debian は不安定)
      if [[ "$INSTALL_ALACRITTY" == true ]]; then
        if apt-cache show alacritty >/dev/null 2>&1; then
          install_pkg alacritty
        else
          warn "alacritty not in apt repo; install manually on this distro"
        fi
      fi

      # neovim: ubuntu/debian の apt 版は古い場合あり (要バージョン確認)
      if [[ "$INSTALL_NEOVIM" == true ]]; then
        # Debian: tree-sitter-cli は npm 経由で導入 (Phase 6相当)
        install_pkg neovim nodejs npm
      fi
      # starship, sheldon, uv は apt にないため Phase 6 で導入
      ;;
  esac
  echo

  # ----------------------------------------------------------------
  # Phase 6: Official script installers (fallback)
  # ----------------------------------------------------------------
  # Phase 5 で導入できなかったツールを公式スクリプト経由で導入
  # 既にインストール済みの場合は各関数内でスキップされる
  log "Phase 6/6: Official script installers (for missing tools)"
  export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"

  # 必須ツール (全環境で必要)
  install_sheldon_script
  install_uv_script
  install_zoxide_script

  # オプションツール (フラグに応じて)
  if [[ "$INSTALL_STARSHIP" == true ]]; then
    install_starship_script
  fi

  # neovim を入れる場合のみ tree-sitter-cli を npm 経由で導入
  # Arch は Phase 5 で tree-sitter パッケージを導入済みなのでスキップ
  if [[ "$INSTALL_NEOVIM" == true ]] && [[ "$DISTRO_FAMILY" != "arch" ]]; then
    install_tree_sitter_cli
  fi
  echo

  # ----------------------------------------------------------------
  # Final verification
  # ----------------------------------------------------------------
  # 全インストール終了後の確認
  # 必須コマンドが揃っているかチェックし、不足があれば警告
  log "Final verification..."
  echo

  # 必須コマンドリスト
  # Note: パッケージ名とコマンド名が異なるツールに注意
  #   - ripgrep (package) → rg (command), 全ディストロ共通
  #   - fd-find (package, Fedora/Debian) → fd or fdfind (command, distroで異なる)
  local required=(
    zsh git curl              # base
    sheldon uv                # zsh plugin / Python
    bat rg eza fzf zoxide     # modern CLI (ripgrep のコマンド名は rg)
  )

  # fd は Debian でのみコマンド名が fdfind
  # 他のディストロでは fd というコマンド名
  case "$DISTRO_FAMILY" in
    arch|fedora)
      required+=(fd)
      ;;
    debian)
      required+=(fdfind)
      ;;
  esac

  local optional=()
  local missing=()

  # 必須コマンドのチェック (不足はエラー扱い)
  for cmd in "${required[@]}"; do
    if has "$cmd"; then
      ok "$cmd"
    else
      missing+=("$cmd")
    fi
  done

  # オプションコマンドのチェック (不足は警告のみ)
  for cmd in "${optional[@]}"; do
    if has "$cmd"; then
      ok "$cmd (optional)"
    else
      warn "$cmd (optional): not installed"
    fi
  done

  echo
  if (( ${#missing[@]} > 0 )); then
    warn "Missing required commands: ${missing[*]}"
    warn "Try re-running bootstrap.sh or install them manually."
  else
    ok "All required tools are installed!"
  fi

  # ----------------------------------------------------------------
  # Next steps message
  # ----------------------------------------------------------------
  echo
  log "Bootstrap complete. Next steps:"
  echo "  1. cd ~/.dotfiles"
  echo "  2. ./deploy.sh [client|server]"
  echo "  3. exec zsh"
}

# ============================================================================
# Script entry point
# ============================================================================
# "$@" でコマンドライン引数をそのまま main に渡す
main "$@"
