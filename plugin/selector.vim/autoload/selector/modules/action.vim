function! s:_vital() abort "{{{
  let l:vital = selector#modules#load('App.Action')
  return l:vital
endfunction "}}}

function! selector#modules#action#init() abort "{{{
  let l:vital = s:_vital()
  return l:vital.App.Action.init()
endfunction "}}}

function! selector#modules#action#call(name, ...) abort "{{{
  let l:options = a:000
  let l:vital = s:_vital()
  return l:vital.App.Action.call(a:name, l:options)
endfunction "}}}

function! selector#modules#action#list(...) abort "{{{
  let l:conceal = a:000
  let l:vital = s:_vital()
  return l:vital.App.Action.list(l:conceal)
endfunction "}}}

function! selector#modules#action#set_prefix(new_prefix) abort "{{{
  let l:vital = s:_vital()
  return l:vital.App.Action.set_prefix(a:new_prefix)
endfunction "}}}

function! selector#modules#action#get_prefix() abort "{{{
  let l:vital = s:_vital()
  return l:vital.App.Action.get_prefix()
endfunction "}}}

function! selector#modules#action#set_hiddens(names) abort "{{{
  let l:vital = s:_vital()
  return l:vital.App.Action.set_hiddens(a:names)
endfunction "}}}

function! selector#modules#action#get_hiddens() abort "{{{
  let l:vital = s:_vital()
  return l:vital.App.Action.get_hiddens()
endfunction "}}}

function! selector#modules#action#set_ignores(names) abort "{{{
  let l:vital = s:_vital()
  return l:vital.App.Action.set_ignores(a:names)
endfunction "}}}

function! selector#modules#action#get_ignores() abort "{{{
  let l:vital = s:_vital()
  return l:vital.App.Action.get_ignores()
endfunction "}}}

