scriptencoding utf-8
if exists('g:loaded_bookmarks')
    finish
endif
let g:loaded_bookmarks = 1

let s:bookmarks_default_dir = exists('$XDG_DATA_HOME') ?
  \ '$XDG_DATA_HOME//bookmarks.vim' :
  \ '$HOME/.local/share//bookmarks.vim'

let g:bookmarks_dir = get(g:,'bookmarks_dir', s:bookmarks_default_dir)
let g:bookmarks_text_len = get(g:,'bookmarks_text_len', 30)

command! BookmarksAddCurrentFile call bookmarks#add()
command! BookmarksOpen exe 'edit ' . bookmarks#get_bookmark_file('')
" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
