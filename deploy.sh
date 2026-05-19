#!/bin/sh

# エラー発生時、または未定義変数参照時にスクリプトを終了させる（堅牢性の向上）
set -eu

# 使い方表示関数
usage() {
  echo "Usage: $0 [-c|-client] [-s|-server]"
  exit 1
}

# 引数の解析（デフォルトは client）
ARGS="client"
case "${1:-}" in
-client | -c | "") ARGS="client" ;;
-server | -s) ARGS="server" ;;
*) usage ;;
esac

### Variables ###
DOTFILES_PATH=$(cd "$(dirname "$0")" && pwd)

# 設定元（dotfiles側）のパス
DOTFILES_ZSH_PATH="${DOTFILES_PATH}/zsh"
DOTFILES_VIM_PATH="${DOTFILES_PATH}/vim"
DOTFILES_NVIM_PATH="${DOTFILES_PATH}/nvim"
DOTFILES_ALACRITTY_PATH="${DOTFILES_PATH}/alacritty"

# 配置先（HOME側）のパス
CONFIG_DIR="${HOME}/.config"
VIM_CONFIG_PATH="${HOME}/.vim"
NVIM_CONFIG_PATH="${CONFIG_DIR}/nvim"
ALACRITTY_CONFIG_PATH="${CONFIG_DIR}/alacritty"

### Helper Functions ###

# シンボリックリンクを安全に作成する共通関数
deploy_link() {
  local src="$1"
  local dst="$2"
  local name="$3"

  # ターゲットの親ディレクトリが存在しない場合は作成
  local dst_dir
  dst_dir=$(dirname "$dst")
  if [ ! -d "$dst_dir" ]; then
    mkdir -p "$dst_dir"
  fi

  # 既存のリンク、ファイル、ディレクトリを安全に削除
  if [ -L "$dst" ] || [ -e "$dst" ]; then
    rm -rf "$dst"
  fi

  ln -sf "$src" "$dst"
  echo "Created symbolic link for [$name] at: $dst"
}

### Main Deployment Flow ###

echo "Starting deployment in [$ARGS] mode..."

# 1. zsh (client / server 両方で必ず実行)
deploy_link "${DOTFILES_ZSH_PATH}/zshrc" "${HOME}/.zshrc" "zshrc"
deploy_link "${DOTFILES_ZSH_PATH}/sheldon" "${CONFIG_DIR}/sheldon" "sheldon"

# 2. Vim (client / server 両方で必ず実行)
deploy_link "${DOTFILES_VIM_PATH}" "${VIM_CONFIG_PATH}" "Vim"

# 3. Neovim (clientの場合は必須、serverの場合はインストール済みの場合のみ)
if [ "$ARGS" = "client" ]; then
  deploy_link "${DOTFILES_NVIM_PATH}" "${NVIM_CONFIG_PATH}" "Neovim"
elif [ "$ARGS" = "server" ]; then
  # nvim コマンドが存在するかチェック
  if command -v nvim >/dev/null 2>&1; then
    deploy_link "${DOTFILES_NVIM_PATH}" "${NVIM_CONFIG_PATH}" "Neovim (Server)"
  else
    echo "ℹ️  Neovim is not installed. Skipping Neovim configuration."
  fi
fi

# 4. Alacritty (client の場合のみ実行)
if [ "$ARGS" = "client" ]; then
  deploy_link "${DOTFILES_ALACRITTY_PATH}/alacritty.toml" "${ALACRITTY_CONFIG_PATH}/alacritty.toml" "Alacritty"
fi

echo "Dotfiles deployment completed successfully! [Mode: $ARGS]"
