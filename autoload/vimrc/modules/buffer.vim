call vimrc#modules#load('Vim.Buffer')
call vimrc#modules#load('Vim.BufferManager')

function! vimrc#modules#buffer#new_manager() abort "{{{
  let l:vital = vimrc#modules#_vital()
  return l:vital.Vim.BufferManager.new()
endfunction "}}}
