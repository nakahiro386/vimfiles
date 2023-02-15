function! s:_vital() abort "{{{
  let l:vital = selector#modules#load('System.Filepath')
  return l:vital
endfunction "}}}

function! selector#modules#filepath#abspath(path) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.Filepath.abspath(a:path)
endfunction "}}}

function! selector#modules#filepath#winpath(path) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.Filepath.winpath(a:path)
endfunction "}}}

function! selector#modules#filepath#realpath(path) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.Filepath.realpath(a:path)
endfunction "}}}
