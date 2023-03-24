function! s:_vital() abort "{{{
  let l:vital = selector#modules#load('Process')
  return l:vital
endfunction "}}}

function! selector#modules#process#system(command, input) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Process.system(a:command, a:input)
endfunction "}}}

function! selector#modules#process#iconv(expr, from, to) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Process.iconv(a:expr, a:from, a:to)
endfunction "}}}
