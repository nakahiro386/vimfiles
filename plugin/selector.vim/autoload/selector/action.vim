function! s:quit() abort "{{{
  let l:bufname = b:_selector['buffer_info'].bufname
  let l:previous_winid = win_getid(winnr('#'))
  call selector#buffer#close(l:bufname)
  call win_gotoid(l:previous_winid)
endfunction "}}}

function! s:wipeout() abort "{{{
  let l:bufname = b:_selector['buffer_info'].bufname
  let l:previous_winid = win_getid(winnr('#'))
  call selector#buffer#wipeout(l:bufname)
  call win_gotoid(l:previous_winid)
endfunction "}}}

let s:default_actions = {
  \   'quit': function('s:quit'),
  \   'wipeout': function('s:wipeout'),
  \ }

function! selector#action#get_default_actions() abort "{{{
  return copy(s:default_actions)
endfunction "}}}

function! selector#action#call(source_name, action_name) abort "{{{
  let l:source = selector#sources#get(a:source_name)

  let l:Action = get(l:source['actions'], a:action_name, "")
  if empty(l:Action)
    let l:Action = s:default_actions[a:action_name]
  endif
  call l:Action()
endfunction "}}}

function! selector#action#reload() abort "{{{
  let l:curpos = getcurpos('.')
  let l:mask = selector#_get_mask()
  call selector#_text_entered(l:mask)
  call setpos('.', l:curpos)
  stopinsert
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
