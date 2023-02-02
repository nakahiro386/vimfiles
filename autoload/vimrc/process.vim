function! vimrc#process#system(command, input) abort "{{{
  return vimrc#modules#process#system(a:command, a:input)
endfunction "}}}

function! vimrc#process#iconv(expr, from, to) abort "{{{
  return vimrc#modules#process#iconv(a:expr, a:from, a:to)
endfunction "}}}
