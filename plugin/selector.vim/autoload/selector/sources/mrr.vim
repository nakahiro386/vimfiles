let s:mrr = {}

function! selector#sources#mrr#init() abort "{{{
  let s:mrr = {
    \   'name': 'mrr',
    \   'contents': function('selector#sources#mr#base#list', ['mrr']),
    \   'actions': {
    \     'open': function('selector#sources#mr#base#open', ['edit']),
    \     'vsplit': function('selector#sources#mr#base#open', ['vsplit']),
    \     'tabopen': function('selector#sources#mr#base#open', ['tabedit']),
    \     'delete': function('selector#sources#mr#base#delete', ['mrr']),
    \   },
    \ }
  return s:mrr
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
