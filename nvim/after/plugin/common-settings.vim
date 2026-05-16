"---------------------------------------------
" タブ/インデントの設定
"---------------------------------------------
" 改行時の自動コメントアウトを無効にする
au FileType * setlocal formatoptions-=ro

"---------------------------------------------
" other setting
"---------------------------------------------
" FileType plaintex -> tex
autocmd FileType plaintex setlocal filetype=tex
