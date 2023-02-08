function! s:_vital() abort "{{{
  let l:vital = vimrc#modules#load('System.Filepath')
  return l:vital
endfunction "}}}

function! vimrc#modules#filepath#abspath(path) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.Filepath.abspath(a:path)
endfunction "}}}

function! vimrc#modules#filepath#winpath(path) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.Filepath.winpath(a:path)
endfunction "}}}

function! vimrc#modules#filepath#realpath(path) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.Filepath.realpath(a:path)
endfunction "}}}
