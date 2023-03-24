function! s:_vital() abort "{{{
  let l:vital = bookmarks#modules#load('System.Filepath')
  return l:vital
endfunction "}}}

function! bookmarks#modules#filepath#join(paths) abort "{{{
  let l:vital = s:_vital()
  return l:vital.System.Filepath.join(a:paths)
endfunction "}}}
