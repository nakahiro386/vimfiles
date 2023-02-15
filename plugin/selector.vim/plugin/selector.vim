scriptencoding utf-8
if exists('g:loaded_selector')
    finish
endif
let g:loaded_selector = 1

command! -bang -nargs=1 -complete=customlist,selector#complete#srouce Selector call selector#open(<q-args>, '<bang>')
" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
