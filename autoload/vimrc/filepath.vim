function! vimrc#filepath#abspath(path) abort "{{{
  return vimrc#modules#filepath#abspath(a:path)
endfunction "}}}

function! vimrc#filepath#realpath(path) abort "{{{
  if g:is_windows
    let l:path = vimrc#modules#filepath#winpath(a:path)
  else
    let l:path = vimrc#modules#filepath#realpath(a:path)
  endif
  return l:path
endfunction "}}}
