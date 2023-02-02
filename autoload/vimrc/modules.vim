let s:V = vital#vimrc#new()

function! vimrc#modules#_vital() abort "{{{
  return s:V
endfunction "}}}

function! vimrc#modules#load(module_name) abort "{{{
  let l:vital = vimrc#modules#_vital()
  call l:vital.load(a:module_name)
endfunction "}}}


