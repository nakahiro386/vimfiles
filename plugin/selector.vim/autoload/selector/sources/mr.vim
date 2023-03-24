let s:mr = {}

function! selector#sources#mr#init() abort "{{{
  function! s:mr_contents(bang) abort "{{{
    let l:mr_list = mapnew(mr#mru#list(), '"mru|" . v:val')
    call extend(l:mr_list, mapnew(mr#mrw#list(), '"mrw|" . v:val'))
    call extend(l:mr_list, mapnew(mr#mrr#list(), '"mrr|" . v:val'))
    return l:mr_list
  endfunction "}}}

  function! s:mr_path() abort "{{{
    let [l:source, l:path] = split(getline("."), "|")
    return [l:source, l:path]
  endfunction "}}}

  function! s:open(cmd, path) abort "{{{
    close
    exe a:cmd . ' ' . a:path
  endfunction "}}}

  function! s:mr_open() abort "{{{
    let [l:source, l:path] = s:mr_path()
    call s:open('edit', l:path)
  endfunction "}}}

  function! s:mr_vsplit() abort "{{{
    let [l:source, l:path] = s:mr_path()
    call s:open('vsplit', l:path)
  endfunction "}}}

  function! s:mr_tabopen() abort "{{{
    let [l:source, l:path] = s:mr_path()
    call s:open('tabedit', l:path)
  endfunction "}}}

  function! s:mr_delete() abort "{{{
    let [l:source, l:path] = s:mr_path()
    call mr#{l:source}#delete(l:path)
    call selector#action#reload()
  endfunction "}}}

  let s:mr = {
    \   'name': 'mr',
    \   'contents': function('s:mr_contents'),
    \   'actions': {
    \     'open': function('s:mr_open'),
    \     'vsplit': function('s:mr_vsplit'),
    \     'tabopen': function('s:mr_tabopen'),
    \     'delete': function('s:mr_delete'),
    \   },
    \ }
  return s:mr
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
