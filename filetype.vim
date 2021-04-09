" @see new-filetype pattern.C
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
  autocmd! BufRead,BufNewFile {,.}vrapperrc setfiletype vim
  autocmd! BufRead,BufNewFile *.{md,mkd} setfiletype markdown
  autocmd! BufRead,BufNewFile *.wlst setfiletype python
augroup END

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
