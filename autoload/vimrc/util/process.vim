let s:V = vimrc#util#_vital()
call s:V.load('Process')

function! vimrc#util#process#system(command, input) abort "{{{
  let l:vital = vimrc#util#_vital()
  return l:vital.Process.system(a:command, a:input)
endfunction "}}}

function! vimrc#util#process#iconv(expr, from, to) abort "{{{
  let l:vital = vimrc#util#_vital()
  return l:vital.Process.iconv(a:expr, a:from, a:to)
endfunction "}}}
