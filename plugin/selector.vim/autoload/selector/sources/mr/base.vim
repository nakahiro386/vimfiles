function! selector#sources#mr#base#list(source, bang) abort "{{{
  return mr#{a:source}#list()
endfunction "}}}

function! selector#sources#mr#base#delete(source) abort "{{{
  let l:path = selector#sources#mr#base#get_path()
  call mr#{a:source}#delete(l:path)
  call selector#action#reload()
endfunction "}}}

function! selector#sources#mr#base#get_path() abort "{{{
  let l:line = getline(".")
  return l:line
endfunction "}}}

function! selector#sources#mr#base#open(cmd) abort "{{{
  let l:path = selector#sources#mr#base#get_path()
  close
  exe a:cmd . ' ' . l:path
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
