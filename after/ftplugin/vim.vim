scriptencoding utf-8
setlocal expandtab
call IndentSet(2)
setlocal autoindent
setlocal smartindent
setlocal foldmethod=marker
setlocal formatoptions-=r
setlocal formatoptions-=o
"接続行のインデント数
" @see ft-vim-indent
if exists('*shiftwidth')
  let g:vim_indent_cont = shiftwidth() * 1
else
  let g:vim_indent_cont = &sw * 1
endif
