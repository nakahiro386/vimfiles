function! s:_vital() abort "{{{
  let l:vital = selector#modules#load('Vim.Buffer', 'Vim.BufferManager')
  return l:vital
endfunction "}}}

function! selector#modules#buffer#new_manager() abort "{{{
  let l:vital = s:_vital()
  return l:vital.Vim.BufferManager.new()
endfunction "}}}
