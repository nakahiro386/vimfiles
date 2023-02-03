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

function! vimrc#tail(path, bang, count) "{{{
  if exists('b:tail_file_path')
    let l:file = b:tail_file_path
  else
    let l:file = fnamemodify(expand(a:path), ':p')

    " 実際に読む込むべきファイルのパスを取得
    let l:prot = matchstr(l:file, ';\(tail\)$')
    if !empty(l:prot)
      let l:file = strpart(l:file, 0, strlen(l:file) - strlen(l:prot))
    endif
  endif

  function! s:tail(info) abort closure "{{{
    let b:buffer_info = a:info
    setlocal noswapfile
    setlocal buftype=nofile
    setlocal filetype=tail
    setlocal nomodeline
    if !a:info.newbuf
      setl modifiable
      silent execute '%del _'
    endif

    " ファイルを読み込んで、バッファにセットする。
    if filereadable(l:file)
      if a:bang == '!'
        call setline(1, readfile(l:file))
      else
        call setline(1, readfile(l:file, '', a:count * -1))
      endif
    else
      call setline(1, printf('ERROR!!! filereadable(%s)', l:file))
    endif
    let b:tail_file_path = l:file
    let b:tail_read_count = a:count

    setlocal nomodifiable
    nnoremap <silent> <buffer> <F5> :<C-u>exe b:tail_read_count .. 'TailRead %'<CR>
    nnoremap <silent> <buffer> <S-F5> :<C-u>exe b:tail_read_count .. 'TailRead! %'<CR>
    nnoremap <buffer> <silent> q :<C-U>call vimrc#buffer#close(b:buffer_info.bufname)<CR>
    nnoremap <buffer> <silent> Q :<C-U>call vimrc#buffer#wipeout(b:buffer_info.bufname)<CR>
    command! -buffer TailReadOrig exe 'tabe '.b:tail_file_path
    exe 'normal! G'
  endfunction "}}}

  " バッファを作る
  let l:guard = vimrc#util#store('&eventignore')
  try
    let &eventignore = 'all'
    let b:buffer_info = vimrc#buffer#open({'bufname': l:file.';tail',
      \   'config': {},
      \   'opened': function('s:tail'),
      \ })
  finally
    call l:guard.restore()
  endtry
endfunction "}}}

function! vimrc#redir(bang, cmd) abort "{{{
  let l:Redir = vimrc#util#capture(a:cmd)
  if a:bang != '!'
    execute 'tabnew'
  endif
  execute ''.(a:bang != '!' ? '0' : '').'put =l:Redir'
endfunction "}}}

function! vimrc#get_project_directory() abort "{{{
  let l:dir = vimrc#util#path2project_directory(expand('%:p'), 1)
  return l:dir
endfunction "}}}
