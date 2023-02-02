function! vimrc#process#system(command, input) abort "{{{
  return vimrc#util#process#system(a:command, a:input)
endfunction "}}}

function! vimrc#process#iconv(expr, from, to) abort "{{{
  return vimrc#util#process#iconv(a:expr, a:from, a:to)
endfunction "}}}
