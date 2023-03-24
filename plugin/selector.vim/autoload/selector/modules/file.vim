function! s:_vital() abort "{{{
  let l:vital = selector#modules#load('System.File')
  return l:vital
endfunction "}}}

function! selector#modules#file#open(filename) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.File.open(a:filename)
endfunction "}}}

function! selector#modules#file#copy(src, dest) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.File.copy(a:src, a:dest)
endfunction "}}}
