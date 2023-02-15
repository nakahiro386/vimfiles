function! s:quit() abort "{{{
  call selector#buffer#close(b:_selector['buffer_info'].bufname)
endfunction "}}}

function! s:wipeout() abort "{{{
  call selector#buffer#wipeout(b:_selector['buffer_info'].bufname)
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

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
