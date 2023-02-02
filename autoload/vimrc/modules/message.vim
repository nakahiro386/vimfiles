call vimrc#modules#load('Vim.Message')

function! s:_format_message(msg) abort "{{{
  return (vimrc#util#is_string(a:msg) ? a:msg : string(a:msg))
    \ ->split("\n")
    \ ->map({_, val -> printf("[%s]%s", s:V.plugin_name(), val)})
    \ ->join("\n")
endfunction "}}}

function! vimrc#modules#message#warn(msg) abort "{{{
  let l:vital = vimrc#modules#_vital()
  call l:vital.Vim.Message.warn(s:_format_message(a:msg))
endfunction "}}}

function! vimrc#modules#message#error(msg) abort "{{{
  let l:vital = vimrc#modules#_vital()
  call l:vital.Vim.Message.error(s:_format_message(a:msg))
endfunction "}}}

function! vimrc#modules#message#capture(command) abort "{{{
  let l:vital = vimrc#modules#_vital()
  return l:vital.Vim.Message.capture(a:command)
endfunction "}}}

