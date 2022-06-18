let s:V = vital#vimrc#new()

function! vimrc#util#_vital() abort "{{{
  return s:V
endfunction "}}}

let s:Prelude = s:V.import('Prelude')
function! vimrc#util#is_string(value) abort "{{{
  return s:Prelude.is_string(a:value)
endfunction "}}}

function! vimrc#util#is_list(value) abort "{{{
  return s:Prelude.is_list(a:value)
endfunction "}}}

let s:Guard = s:V.import('Vim.Guard')
function! vimrc#util#store(targets) abort "{{{

  let l:targets = []
  if vimrc#util#is_string(a:targets)
    call add(l:targets, a:targets)
  elseif vimrc#util#is_list(a:targets)
    let l:targets += a:targets
  endif
  call filter(l:targets, {idx, val -> exists(val)})

  return s:Guard.store(l:targets)
endfunction "}}}
