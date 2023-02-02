call vimrc#modules#load('Prelude')
call vimrc#modules#load('Vim.Guard')

function! vimrc#modules#common#is_string(value) abort "{{{
  let l:vital = vimrc#modules#_vital()
  return l:vital.Prelude.is_string(a:value)
endfunction "}}}

function! vimrc#modules#common#is_list(value) abort "{{{
  let l:vital = vimrc#modules#_vital()
  return l:vital.Prelude.is_list(a:value)
endfunction "}}}

function! vimrc#modules#common#is_number(value) abort "{{{
  let l:vital = vimrc#modules#_vital()
  return l:vital.Prelude.is_number(a:value)
endfunction "}}}

function! vimrc#modules#common#set_default(var, val) abort "{{{
  let l:vital = vimrc#modules#_vital()
  return l:vital.Prelude.set_default(a:var, a:val)
endfunction "}}}

function! vimrc#modules#common#path2project_directory(path, is_allow_empty) abort "{{{
  let l:vital = vimrc#modules#_vital()
  let l:dir = l:vital.Prelude.path2project_directory(a:path, a:is_allow_empty)
  return l:dir
endfunction "}}}

function! vimrc#modules#common#store(targets) abort "{{{
  let l:vital = vimrc#modules#_vital()
  return l:vital.Vim.Guard.store(a:targets)
endfunction "}}}
