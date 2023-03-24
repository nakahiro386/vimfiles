function! s:_vital() abort "{{{
  let l:vital = selector#modules#load('Prelude')
  return l:vital
endfunction "}}}

function! selector#modules#common#is_string(value) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Prelude.is_string(a:value)
endfunction "}}}

function! selector#modules#common#is_list(value) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Prelude.is_list(a:value)
endfunction "}}}

function! selector#modules#common#is_number(value) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Prelude.is_number(a:value)
endfunction "}}}

function! selector#modules#common#set_default(var, val) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Prelude.set_default(a:var, a:val)
endfunction "}}}

function! selector#modules#common#path2project_directory(path, is_allow_empty) abort "{{{
  let l:vital = s:_vital()
  let l:dir = l:vital.Prelude.path2project_directory(a:path, a:is_allow_empty)
  return l:dir
endfunction "}}}
