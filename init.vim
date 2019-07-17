let g:vimrc_path = expand("<sfile>:p:h") . "/vimrc"
execute 'source ' . g:vimrc_path
let $MYVIMRC = g:vimrc_path

" $VIMFILES/init_local.vim
" let g:python3_host_prog = '/path/to/python3'

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
