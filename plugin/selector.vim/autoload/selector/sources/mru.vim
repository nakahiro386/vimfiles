let s:mru = {}

function! selector#sources#mru#init() abort "{{{
  let s:mru = {
    \   'name': 'mru',
    \   'contents': function('selector#sources#mr#base#list', ['mru']),
    \   'actions': {
    \     'open': function('selector#sources#mr#base#open', ['edit']),
    \     'vsplit': function('selector#sources#mr#base#open', ['vsplit']),
    \     'tabopen': function('selector#sources#mr#base#open', ['tabedit']),
    \     'delete': function('selector#sources#mr#base#delete', ['mru']),
    \   },
    \ }
  return s:mru
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
