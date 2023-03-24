function! s:_vital() abort "{{{
  let l:vital = vimrc#modules#load('Vim.Buffer', 'Vim.BufferManager')
  return l:vital
endfunction "}}}

function! vimrc#modules#buffer#new_manager() abort "{{{
  let l:vital = s:_vital()
  return l:vital.Vim.BufferManager.new()
endfunction "}}}
