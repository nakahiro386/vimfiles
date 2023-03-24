let s:buffers = {}

function! selector#sources#buffers#init() abort "{{{
  function! s:buffers_contents(bang) abort "{{{
    let l:contents = split(selector#util#capture('buffers'.a:bang), "\n")
    return l:contents
  endfunction "}}}

  function! s:_bufnr() abort "{{{
    let l:line = getline(".")
    let l:bufnr = matchstr(l:line, '^\s*\zs\d\+')
    return l:bufnr
  endfunction "}}}

  function! s:buffers_open() abort "{{{
    let l:bufnr = s:_bufnr()
    close
    exe 'buffer '.l:bufnr
  endfunction "}}}

  function! s:buffers_tabopen() abort "{{{
    let l:bufnr = s:_bufnr()
    close
    exe 'tab sbuffer '.l:bufnr
  endfunction "}}}

  function! s:buffers_split() abort "{{{
    let l:bufnr = s:_bufnr()
    close
    exe 'rightbelow sbuffer '.l:bufnr
  endfunction "}}}

  function! s:buffers_vsplit() abort "{{{
    let l:bufnr = s:_bufnr()
    close
    exe 'rightbelow vertical sbuffer '.l:bufnr
  endfunction "}}}

  function! s:buffers_delete() abort "{{{
    let l:bufnr = s:_bufnr()
    exe l:bufnr.'bwipeout'
    call selector#action#reload()
  endfunction "}}}

  let s:buffers = {
    \   'name': 'buffers',
    \   'contents': function('s:buffers_contents'),
    \   'actions': {
    \     'open': function('s:buffers_open'),
    \     'tabopen': function('s:buffers_tabopen'),
    \     'split': function('s:buffers_split'),
    \     'vsplit': function('s:buffers_vsplit'),
    \     'delete': function('s:buffers_delete'),
    \   },
    \ }
  return s:buffers
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
