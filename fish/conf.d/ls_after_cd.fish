# --------------------------------------------
# cdコマンド後、ls を実行する
# --------------------------------------------
functions --copy cd standard_cd

function cd
  standard_cd $argv; and ls
end
