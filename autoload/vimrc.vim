function! vimrc#set_indent(...) abort "{{{
  if empty(a:000)
    execute 'setlocal tabstop?'
    execute 'setlocal shiftwidth?'
    execute 'setlocal softtabstop?'
    return
  endif
  if !vimrc#util#is_number(a:1)
    call vimrc#util#error('Argument must be Number : args ' .. a:1)
    return
  endif
  if a:1 < 1
    call vimrc#util#error('Argument must be positive : args ' .. a:1)
    return
  endif
  execute 'setlocal tabstop=' .. a:1
  execute 'setlocal shiftwidth=' .. a:1
  execute 'setlocal softtabstop=' .. a:1
endfunction "}}}
