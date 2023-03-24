let s:scriptnames = {}

function! selector#sources#scriptnames#init() abort "{{{
  function! s:scriptnames_contents(bang) abort "{{{
    let l:contents = split(selector#util#capture('scriptnames'), "\n")
    return l:contents
  endfunction "}}}

  function! s:scriptnames_path() abort "{{{
    let l:line = getline(".")
    let l:path = matchstr(l:line, '^.*:\s*\zs.*$')
    return l:path
  endfunction "}}}

  function! s:scriptnames_open() abort "{{{
    let l:path = s:scriptnames_path()
    close
    exe 'edit ' . l:path
  endfunction "}}}

  function! s:scriptnames_tabopen() abort "{{{
    let l:path = s:scriptnames_path()
    close
    exe 'tabedit ' . l:path
  endfunction "}}}

  let s:scriptnames = {
    \   'name': 'scriptnames',
    \   'contents': function('s:scriptnames_contents'),
    \   'actions': {
    \     'open': function('s:scriptnames_open'),
    \     'tabopen': function('s:scriptnames_tabopen'),
    \   },
    \ }
  return s:scriptnames
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
