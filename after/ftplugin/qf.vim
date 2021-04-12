scriptencoding utf-8
setlocal colorcolumn&
setlocal cursorline
nnoremap <buffer> q :<C-U>bw<CR>
nnoremap <buffer> Q :<C-U>bw<CR>
nnoremap <buffer> p :<c-u>exe 'pedit +' . split(getline("."), '\|')[1] . ' ' . split(getline("."), '\|')[0]<cr>

nnoremap <buffer> <cr> <C-w><cr>
nnoremap <buffer> <C-w><cr> <cr>

if exists(':Qfreplace') is 2
  nnoremap <buffer> r :<C-u>Qfreplace<CR>
endif
