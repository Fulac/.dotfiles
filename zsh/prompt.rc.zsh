# --------------------------------------------
# Prompt
# --------------------------------------------
# プロンプトに色を付ける
autoload -U colors; colors

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# 一般ユーザ時
# 通常のプロンプト
tmp_prompt="%{${fg[white]}%}%n%# %{${reset_color}%}"
# セカンダリのプロンプト (コマンドが２行以上のときに表示される)
tmp_prompt2="%{${fg[white]}%}%_> %{${reset_color}%}"
# 右側のプロンプト
tmp_rprompt="%{${fg[green]}%}[%~]%{${reset_color}%}"
# スペル訂正用のプロンプト
tmp_sprompt="%{${fg[yellow]}%}%r is correct? [Yes, No, Abort, Edit]:%{${reset_color}%}"

# rootユーザ時(太字にし、アンダーバーをつける)
if [ ${UID} -eq 0 ]; then
  tmp_prompt="%{${fg[red]}%}%n%# %{${reset_color}%}"
  tmp_prompt2="%{${fg[red]}%}%_> %{${reset_color}%}"
  tmp_rprompt="${tmp_rprompt}%u%b"
  tmp_sprompt="${tmp_sprompt}%u%b"
fi

# 通常のプロンプト
PROMPT=$tmp_prompt
# セカンダリのプロンプト
PROMPT2=$tmp_prompt2
# 右側のプロンプト
RPROMPT=$tmp_rprompt
# スペル訂正用のプロンプト
SPROMPT=$tmp_sprompt

# SSHログイン時のプロンプト
[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] &&
  PROMPT="%{${fg[red]}%}${HOST%%.*} ${PROMPT}"
;


# --------------------------------------------
# Title (user@hostname)
# --------------------------------------------
case "${TERM}" in
  kterm*|xterm*)
    precmd() {
      echo -ne "\033]0;${USER}@${HOST%%.*}\007"
    }
    ;;
esac


# --------------------------------------------
# Ls Color
# --------------------------------------------
# 色の設定
export LSCOLORS=Exfxcxdxbxegedabagacad

# 補完時の色の設定
export LS_COLORS='di=01;34:ln=01;35:so=01;32:ex=01;31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'

# ZLS_COLORSとは？
export ZLS_COLORS=$LS_COLORS

# lsコマンド時、自動で色がつく(ls -Gのようなもの？)
export CLICOLOR=true

# 補完候補に色を付ける
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}


# --------------------------------------------
# Complement
# --------------------------------------------
# 補完機能を有効にする
autoload -U compinit; compinit

# 補完候補を一覧で表示する(d)
setopt auto_list

# 補完キー連打で補完候補を順に表示する(d)
setopt auto_menu

# 補完候補をできるだけ詰めて表示する
setopt list_packed

# 補完候補にファイルの種類も表示する
setopt list_types

# Shift-Tabで補完候補を逆順する("\e[Z")
bindkey "^[[Z" reverse-menu-complete

# 補完時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完リストのカーソル部分をハイライトする
zstyle ':completion:*:default' menu select=2

# 補完関数の表示を強化する
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT

# マッチ種別を別々に表示
zstyle ':completion:*' group-name ''

# 今いるディレクトリを補完候補から外す
#zstyle ':completion:*' ignore-parents parent pwd ..

# フルパスの時でも今のディレクトリを外す場合の設定
zstyle ':completion:*' ignore-parents parent pwd

# セパレータを設定する
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true

# cd -<Tab> で今までに行ったディレクトリを表示かつ移動
setopt auto_pushd


# --------------------------------------------
# Glob
# --------------------------------------------
# グロブ機能を拡張する
setopt extended_glob

# ファイルグロブで大文字小文字を区別しない
unsetopt caseglob
