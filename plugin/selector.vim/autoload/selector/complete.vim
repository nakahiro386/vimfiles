function! selector#complete#srouce(arglead, cmdline, cursorpos) abort "{{{
  let l:sources = sort(keys(selector#sources#get()))
  return filter(l:sources, 'v:val =~ "^".a:arglead')
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
