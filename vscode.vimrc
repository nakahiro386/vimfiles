noremap  s       <Nop>
noremap  gs      <Nop>
noremap  S       <Nop>
noremap  Q       <Nop>

nnoremap : ;
noremap ; :

noremap k gk
noremap j gj
noremap gk k
noremap gj j
vnoremap sh ^
nnoremap sl g$
vnoremap sl g_
onoremap sl g_

nnoremap gl g$
vnoremap gl g_
onoremap gl g_

vnoremap sa oggoG

nnoremap <Leader>l gt
nnoremap <Leader>h gT


noremap Y y$
noremap <Del> "xx
noremap x "xx
noremap X "xD
nnoremap d "dd
vnoremap d "dd
noremap D "dD
nnoremap c "cc
vnoremap c "cc
noremap C "cC
nnoremap dp "dp
nnoremap dP "dP
nnoremap cp "cp
nnoremap cP "cP

nnoremap <Leader>q :q<CR>
nnoremap <Leader>Q :Q!<CR>
nnoremap <Leader>wq <C-w>q

nnoremap <Leader>wr :<C-U>write<CR>

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker: