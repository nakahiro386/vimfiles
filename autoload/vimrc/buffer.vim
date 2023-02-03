let s:Buffer_cache = {}

function! s:get_buffer_manager(bufname) abort "{{{
  let l:bm = get(s:Buffer_cache, a:bufname, {})
  if empty(l:bm)
    let l:bm = vimrc#modules#buffer#new_manager()
    let s:Buffer_cache[a:bufname] = l:bm
  endif
  return l:bm
endfunction "}}}

function! vimrc#buffer#open(config) abort "{{{
  let l:bufname = a:config['bufname']
  let l:config = a:config['config']
  let l:Opened = a:config['opened']

  let l:bm = s:get_buffer_manager(l:bufname)
  let l:bm.opened = l:Opened
  let l:info = l:bm.open(l:bufname, l:config)
  return l:info
endfunction "}}}

function! vimrc#buffer#close(bufname) abort "{{{
  let l:bm = s:get_buffer_manager(a:bufname)
  call l:bm.close()
endfunction "}}}

function! vimrc#buffer#wipeout(bufname) abort "{{{
  let l:bm = s:get_buffer_manager(a:bufname)
  let s:Buffer_cache[a:bufname] = v:false
  call l:bm.do('bwipeout')
endfunction "}}}
