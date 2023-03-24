let s:V = {}

function! bookmarks#modules#load(...) abort "{{{
  if empty(s:V)
    let s:V = vital#bookmarks#new()
  endif
  for l:module in a:000
    if !empty(l:module) && !has_key(s:V, l:module)
      call s:V.load(l:module)
    endif
  endfor
  return s:V
endfunction "}}}
