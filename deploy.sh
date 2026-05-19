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

# Neovim用 Python仮想環境のパス
NVIM_VENV_PATH="${HOME}/.local/share/nvim/venv"
NVIM_VENV_PYTHON="${NVIM_VENV_PATH}/bin/python"

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

# Neovim用のPython仮想環境をuvで構築する関数
setup_nvim_python_env() {
  echo "Checking dependencies for Neovim Python environment..."

  # nvim, python, uv のすべてがインストールされているか確認
  if command -v nvim >/dev/null 2>&1 &&
     command -v python >/dev/null 2>&1 &&
     command -v uv >/dev/null 2>&1; then

    # すでに仮想環境があり、pynvimが導入済みかチェック
    if [ -x "$NVIM_VENV_PYTHON" ] && "$NVIM_VENV_PYTHON" -c "import pynvim" >/dev/null 2>&1; then
      echo "Neovim Python venv and pynvim are already configured. Skipping setup."
    else
      echo "Setting up Neovim Python environment using uv..."
      mkdir -p "$(dirname "$NVIM_VENV_PATH")"

      # 既存の不完全なディレクトリがあれば削除してクリーンインストール
      [ -d "$NVIM_VENV_PATH" ] && rm -rf "$NVIM_VENV_PATH"

      uv venv "$NVIM_VENV_PATH"
      uv pip install pynvim --python "$NVIM_VENV_PYTHON"
      echo "Neovim Python environment configured successfully at: $NVIM_VENV_PATH"
    fi
  else
    echo "Skipping Neovim Python env setup: nvim, python, or uv is missing."
  fi
}

### Main Deployment Flow ###

echo "Starting deployment in [$ARGS] mode..."

# zsh (client / server 両方で必ず実行)
deploy_link "${DOTFILES_ZSH_PATH}/zshrc" "${HOME}/.zshrc" "zshrc"
deploy_link "${DOTFILES_ZSH_PATH}/sheldon" "${CONFIG_DIR}/sheldon" "sheldon"

# Vim (client / server 両方で必ず実行)
deploy_link "${DOTFILES_VIM_PATH}" "${VIM_CONFIG_PATH}" "Vim"

# Neovim (clientの場合は必須、serverの場合はインストール済みの場合のみ)
IS_NVIM_INSTALLED=false
if command -v nvim >/dev/null 2>&1; then
  IS_NVIM_INSTALLED=true
fi

if [ "$ARGS" = "client" ]; then
  deploy_link "${DOTFILES_NVIM_PATH}" "${NVIM_CONFIG_PATH}" "Neovim"
elif [ "$ARGS" = "server" ]; then
  if [ "$IS_NVIM_INSTALLED" = true ]; then
    deploy_link "${DOTFILES_NVIM_PATH}" "${NVIM_CONFIG_PATH}" "Neovim (Server)"
  else
    echo "ℹ️  Neovim is not installed. Skipping Neovim configuration."
  fi
fi

# Neovim用 Python 仮想環境の構築処理
# clientモード、またはserverモードで既にnvimが導入されている場合に評価
if [ "$ARGS" = "client" ] || [ "$IS_NVIM_INSTALLED" = true ]; then
  setup_nvim_python_env
fi

# Alacritty (client の場合のみ実行)
if [ "$ARGS" = "client" ]; then
  deploy_link "${DOTFILES_ALACRITTY_PATH}/alacritty.toml" "${ALACRITTY_CONFIG_PATH}/alacritty.toml" "Alacritty"
fi

echo "Dotfiles deployment completed successfully! [Mode: $ARGS]"
