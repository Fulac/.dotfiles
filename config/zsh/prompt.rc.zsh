# --------------------------------------------
# Prompt
# --------------------------------------------
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst

# Git情報の取得 (vcs_info)
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats ' (%b)'
zstyle ':vcs_info:*' actionformats ' (%b|%a)'

# フック関数の登録 (add-zsh-hook を使用)
autoload -Uz add-zsh-hook

_update_vcs_info() {
  # プロンプト表示前にGit情報を更新
  vcs_info
}
add-zsh-hook precmd _update_vcs_info

# プロンプトの組み立て
local p_userhost=""

# rootユーザ、またはSSH接続時のホスト名強調
if [[ ${UID} -eq 0 ]]; then
  p_userhost="%F{red}%n@%m%f "
elif [[ -n "${SSH_TTY}" || -n "${SSH_CLIENT}" ]]; then
  p_userhost="%F{magenta}%n@%m%f "
else
  p_userhost="%F{white}%n%f "
fi

# 通常のプロンプト (ユーザー名/ホスト名 + 権限記号)
PROMPT="${p_userhost}%# "

# セカンダリのプロンプト
PROMPT2="%F{white}%_> %f"

# 右側のプロンプト (ディレクトリパス + Gitブランチ名)
RPROMPT="%F{green}[%~]%f%F{yellow}\${vcs_info_msg_0_}%f"

# スペル訂正用のプロンプト
SPROMPT="%F{yellow}%r is correct? [Yes, No, Abort, Edit]:%f"
