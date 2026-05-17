#!/bin/sh

if [ $# -ge 2 ]; then
  echo "Usage: $0 -client(-c) or -server(-s) (Default: -client)"
  exit 1
fi

args=${1:-client}

### Variables ###
DOTFILES_PATH=$(cd $(dirname $0); pwd)
DOTFILES_ZSH_PATH="${DOTFILES_PATH}/zsh"
DOTFILES_FISH_PATH="${DOTFILES_PATH}/fish"
DOTFILES_VIM_PATH="${DOTFILES_PATH}/vim"
DOTFILES_NVIM_PATH="${DOTFILES_PATH}/nvim"
DOTFILES_GHOSTTY_PATH="${DOTFILES_PATH}/ghostty"
FISH_CONFIG_PATH="${HOME}/.config/fish"
VIM_CONFIG_PATH="${HOME}/.vim"
NVIM_CONFIG_PATH="${HOME}/.config/nvim"
GHOSTTY_CONFIG_PATH="${HOME}/.config/ghostty"

### zsh ###
ln -sf ${DOTFILES_ZSH_PATH}/zshrc ${HOME}/.zshrc
echo "make symbolic link '.zshrc' at ${HOME}"

if [ ! -d ${HOME}.config ]; then
  mkdir -p ${HOME}/.config
fi
ln -sf ${DOTFILES_ZSH_PATH}/sheldon ${HOME}/.config/sheldon
echo "make symbolic link '.config/sheldon' at ${DOTFILES_ZSH_PATH}/sheldon"

### fish ###
#if [ -d ${FISH_CONFIG_PATH} ]; then
#  # config.fish
#  if [ -e ${FISH_CONFIG_PATH}/config.fish ]; then
#    unlink ${FISH_CONFIG_PATH}/config.fish
#  fi
#  ln -sf ${DOTFILES_FISH_PATH}/config.fish ${FISH_CONFIG_PATH}/config.fish
#  echo "make symbolic link 'fish/config.fish' at ${FISH_CONFIG_PATH}"
#
#  # ls_after_cd.fish
#  if [ -e ${FISH_CONFIG_PATH}/conf.d/ls_after_cd.fish ]; then
#    unlink ${FISH_CONFIG_PATH}/conf.d/ls_after_cd.fish
#  fi
#  ln -sf ~/dotfiles/fish/conf.d/ls_after_cd.fish ${FISH_CONFIG_PATH}/conf.d/ls_after_cd.fish
#  echo "make symbolic link 'fish/conf.d/ls_after_cd.fish' at ${FISH_CONFIG_PATH}/fish/conf.d"
#
#  # fish_prompt.fish
#  if [ -e ${FISH_CONFIG_PATH}/functions/fish_prompt.fish ]; then
#    unlink ${FISH_CONFIG_PATH}/functions/fish_prompt.fish
#  fi
#  if [ $args = "-client" ] || [ $args = "-c" ]; then
#    ln -sf ~/dotfiles/fish/functions/fish_prompt.fish ${FISH_CONFIG_PATH}/functions/fish_prompt.fish
#    echo "make symbolic link 'fish/functions/fish_prompt.fish' at ${FISH_CONFIG_PATH}/functions"
#  elif [ $args = "-server" ] || [ $args = "-s" ]; then 
#    ln -sf ~/dotfiles/fish/functions/fish_server_prompt.fish ${FISH_CONFIG_PATH}/functions/fish_prompt.fish
#    echo "make symbolic link 'fish/functions/fish_server_prompt.fish' at ${FISH_CONFIG_PATH}/functions"
#  fi
#fi

### Neovim ###
if [ -L ${NVIM_CONFIG_PATH} ]; then
  unlink ${NVIM_CONFIG_PATH}
elif [ -d ${NVIM_CONFIG_PATH} ]; then
  rm -rf ${NVIM_CONFIG_PATH}
fi
ln -sf ${DOTFILES_NVIM_PATH} ${NVIM_CONFIG_PATH}
echo "make symbolic link 'nvim' at ${HOME}/.config"

### Vim ###
if [ -L ${VIM_CONFIG_PATH} ]; then
  unlink ${VIM_CONFIG_PATH}
elif [ -d ${VIM_CONFIG_PATH} ]; then
  rm -rf ${VIM_CONFIG_PATH}
fi
ln -sf ${DOTFILES_VIM_PATH} ${VIM_CONFIG_PATH}
echo "make symbolic link 'vim' at ${HOME}"

### Ghostty ###
if [[ -L ${GHOSTTY_CONFIG_PATH}/config.ghostty || -f ${GHOSTTY_CONFIG_PATH}/config.ghostty ]]; then
  unlink ${GHOSTTY_CONFIG_PATH}/config.ghostty
else
  mkdir -p ${GHOSTTY_CONFIG_PATH}
fi
ln -sf ${DOTFILES_GHOSTTY_PATH}/config.ghostty ${GHOSTTY_CONFIG_PATH}/config.ghostty
echo "make symbolic link 'ghostty' at ${HOME}/.config/ghostty"
