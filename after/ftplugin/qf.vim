scriptencoding utf-8
setlocal colorcolumn&
setlocal cursorline
nnoremap <buffer> q :<C-U>close<CR>
nnoremap <buffer> Q :<C-U>close<CR>
nnoremap <buffer> p :<c-u>exe 'pedit +' . split(getline("."), '\|')[1] . ' ' . split(getline("."), '\|')[0]<cr>
nnoremap <buffer> t <C-w><cr><C-w>T

nnoremap <buffer> <cr> <C-w><cr>
nnoremap <buffer> <C-w><cr> <cr>

if exists(':Qfreplace') is 2
  nnoremap <buffer> r :<C-u>Qfreplace<CR>
endif
