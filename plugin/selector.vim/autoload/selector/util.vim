function! selector#util#is_string(value) abort "{{{
  return selector#modules#common#is_string(a:value)
endfunction "}}}

function! selector#util#is_list(value) abort "{{{
  return selector#modules#common#is_list(a:value)
endfunction "}}}

function! selector#util#is_number(value) abort "{{{
  return selector#modules#common#is_number(a:value)
endfunction "}}}

function! selector#util#set_default(var, val) abort "{{{
  return selector#modules#common#set_default(a:var, a:val)
endfunction "}}}

function! selector#util#warn(msg) abort "{{{
  redraw
  call selector#modules#message#warn(a:msg)
endfunction "}}}

function! selector#util#error(msg) abort "{{{
  redraw
  call selector#modules#message#error(a:msg)
endfunction "}}}

function! selector#util#capture(command) abort "{{{
  return selector#modules#message#capture(a:command)
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
