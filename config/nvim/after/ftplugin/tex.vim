"---------------------------------------------
" vim-quickrun
"---------------------------------------------
if !exists('g:quickrun_config')
  let g:quickrun_config = {}
endif

let g:quickrun_config['tex'] = {
\   'command' : 'latexmk',
\   'outputter' : 'error',
\   'outputter/error/success' : 'null',
\   'outputter/error/error' : 'quickfix',
\   'cmdopt': '-pdfdvi',
\   'hook/sweep/files' : [
\                         '%S:p:r.aux',
\                         '%S:p:r.bbl',
\                         '%S:p:r.blg',
\                         '%S:p:r.dvi',
\                         '%S:p:r.fdb_latexmk',
\                         '%S:p:r.fls',
\                         '%S:p:r.log',
\                         '%S:p:r.toc',
\                         '%S:p:r.out'
\                        ],
\   'exec': ['%c %o %s']
\}

" 部分的に選択してPDF表示
let g:quickrun_config.tmptex = {
\   'exec': [
\           'mv %s %a/tmptex.latex',
\           'latexmk -pdfdvi -pv -output-directory=%a %a/tmptex.latex',
\           ],
\   'args' : expand("%:p:h:gs?\\\\?/?"),
\   'outputter' : 'error',
\   'outputter/error/success' : 'null',
\   'outputter/error/error' : 'quickfix',
\
\   'hook/eval/enable' : 1,
\   'hook/eval/cd' : "%s:r",
\
\   'hook/eval/template' : '\documentclass{jsarticle}'
\                         .'\usepackage[dvipdfmx]{graphicx, hyperref}'
\                         .'\usepackage{float}'
\                         .'\usepackage{amsmath,amssymb,amsthm,ascmac,mathrsfs}'
\                         .'\allowdisplaybreaks[1]'
\                         .'\theoremstyle{definition}'
\                         .'\newtheorem{theorem}{定理}'
\                         .'\newtheorem*{theorem*}{定理}'
\                         .'\newtheorem{definition}[theorem]{定義}'
\                         .'\newtheorem*{definition*}{定義}'
\                         .'\renewcommand\vector[1]{\mbox{\boldmath{\$#1\$}}}'
\                         .'\begin{document}'
\                         .'%s'
\                         .'\end{document}',
\
\   'hook/sweep/files' : [
\                         '%a/tmptex.latex',
\                         '%a/tmptex.aux',
\                         '%a/tmptex.bbl',
\                         '%a/tmptex.blg',
\                         '%a/tmptex.dvi',
\                         '%a/tmptex.fdb_latexmk',
\                         '%a/tmptex.fls',
\                         '%a/tmptex.log',
\                         '%a/tmptex.toc',
\                         '%a/tmptex.out'
\                        ],
\}

" texファイルの部分表示を Ctrl-l に割り当て (visual mode)
vnoremap <silent><buffer> <C-l> :QuickRun -mode v -type tmptex<CR>

augroup laTeXQuickrun
  au!
  au BufEnter *.tex call <SID>SetLaTeXMainSource()
  au BufEnter *.tex nnoremap <C-k> :call <SID>TexPdfView() <CR>
augroup END

function! s:SetLaTeXMainSource()
  let currentFileDirectory = expand('%:p:h')
  let latexmain = glob(currentFileDirectory . '/*.latexmain')
  if latexmain == ''
    let g:quickrun_config['tex']['srcfile'] = expand('%:p')
  else
    let g:quickrun_config['tex']['srcfile'] = fnamemodify(latexmain, ':r') . '.tex'
  endif
endfunction

function! s:TexPdfView()
  let texPdfFilename = expand('%')
  if exists("g:quickrun_config['tex']['srcfile']")
    let texPdfFilename = fnamemodify(g:quickrun_config['tex']['srcfile'], ':.:r') . '.pdf'
  endif
  if has('unix')
    if executable('mupdf')
      let g:TexPdfViewCommand = '! ' . 'mupdf ' . texPdfFilename
    else
      let g:TexPdfViewCommand = '! ' . 'evince ' . texPdfFilename
    endif
  endif
  execute g:TexPdfViewCommand
endfunction


"---------------------------------------------
" other setting
"---------------------------------------------
" tex用conceal機能を無効化
let g:tex_conceal = ''
