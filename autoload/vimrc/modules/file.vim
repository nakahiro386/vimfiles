function! s:_vital() abort "{{{
  let l:vital = vimrc#modules#load('System.File')
  return l:vital
endfunction "}}}

function! vimrc#modules#file#open(filename) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.File.open(a:filename)
endfunction "}}}

function! vimrc#modules#file#copy(src, dest) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.File.copy(a:src, a:dest)
endfunction "}}}
