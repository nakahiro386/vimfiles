let s:mrw = {}

function! selector#sources#mrw#init() abort "{{{
  let s:mrw = {
    \   'name': 'mrw',
    \   'contents': function('selector#sources#mr#base#list', ['mrw']),
    \   'actions': {
    \     'open': function('selector#sources#mr#base#open', ['edit']),
    \     'vsplit': function('selector#sources#mr#base#open', ['vsplit']),
    \     'tabopen': function('selector#sources#mr#base#open', ['tabedit']),
    \     'delete': function('selector#sources#mr#base#delete', ['mrw']),
    \   },
    \ }
  return s:mrw
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
