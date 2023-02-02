function! vimrc#util#is_string(value) abort "{{{
  return vimrc#modules#common#is_string(a:value)
endfunction "}}}

function! vimrc#util#is_list(value) abort "{{{
  return vimrc#modules#common#is_list(a:value)
endfunction "}}}

function! vimrc#util#is_number(value) abort "{{{
  return vimrc#modules#common#is_number(a:value)
endfunction "}}}

function! vimrc#util#set_default(var, val) abort "{{{
  return vimrc#modules#common#set_default(a:var, a:val)
endfunction "}}}

function! vimrc#util#store(targets) abort "{{{

  let l:targets = []
  if vimrc#modules#is_string(a:targets)
    call add(l:targets, a:targets)
  elseif vimrc#modules#is_list(a:targets)
    let l:targets += a:targets
  endif
  call filter(l:targets, {idx, val -> exists(val)})

  return vimrc#modules#common#store(l:targets)
endfunction "}}}

function! vimrc#util#warn(msg) abort "{{{
  redraw
  call vimrc#modules#message#warn(a:msg)
endfunction "}}}

function! vimrc#util#error(msg) abort "{{{
  redraw
  call vimrc#modules#message#error(a:msg)
endfunction "}}}

function! vimrc#util#capture(command) abort "{{{
  return vimrc#modules#message#capture(a:command)
endfunction "}}}

function! vimrc#util#path2project_directory(path, is_allow_empty) abort "{{{
  return vimrc#modules#common#path2project_directory(a:path, a:is_allow_empty)
endfunction "}}}
