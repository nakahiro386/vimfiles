let s:V = vital#vimrc#new()
call s:V.load('Prelude')
call s:V.load('Vim.Guard')
call s:V.load('Vim.Message')

function! vimrc#util#_vital() abort "{{{
  return s:V
endfunction "}}}

function! vimrc#util#is_string(value) abort "{{{
  let l:vital = vimrc#util#_vital()
  return l:vital.Prelude.is_string(a:value)
endfunction "}}}

function! vimrc#util#is_list(value) abort "{{{
  let l:vital = vimrc#util#_vital()
  return l:vital.Prelude.is_list(a:value)
endfunction "}}}

function! vimrc#util#is_number(value) abort "{{{
  let l:vital = vimrc#util#_vital()
  return l:vital.Prelude.is_number(a:value)
endfunction "}}}

function! vimrc#util#store(targets) abort "{{{

  let l:targets = []
  if vimrc#util#is_string(a:targets)
    call add(l:targets, a:targets)
  elseif vimrc#util#is_list(a:targets)
    let l:targets += a:targets
  endif
  call filter(l:targets, {idx, val -> exists(val)})

  let l:vital = vimrc#util#_vital()
  return l:vital.Vim.Guard.store(l:targets)
endfunction "}}}

function! s:_format_message(msg) abort "{{{
  return (vimrc#util#is_string(a:msg) ? a:msg : string(a:msg))
    \ ->split("\n")
    \ ->map({_, val -> printf("[%s]%s", s:V.plugin_name(), val)})
    \ ->join("\n")
endfunction "}}}

function! vimrc#util#warn(msg) abort "{{{
  redraw
  let l:vital = vimrc#util#_vital()
  call l:vital.Vim.Message.warn(s:_format_message(a:msg))
endfunction "}}}

function! vimrc#util#error(msg) abort "{{{
  redraw
  let l:vital = vimrc#util#_vital()
  call l:vital.Vim.Message.error(s:_format_message(a:msg))
endfunction "}}}
