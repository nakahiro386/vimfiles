let s:V = vimrc#util#_vital()
call s:V.load('System.File')

function! vimrc#util#file#open(filename) abort "{{{
  let l:vital = vimrc#util#_vital()
  return l:vital.System.File.open(a:filename)
endfunction "}}}

function! vimrc#util#file#copy(src, dest) abort "{{{
  let l:vital = vimrc#util#_vital()
  return l:vital.System.File.copy(a:src, a:dest)
endfunction "}}}
