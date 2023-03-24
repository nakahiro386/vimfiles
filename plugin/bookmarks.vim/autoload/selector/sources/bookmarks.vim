let s:bookmarks = {}

function! selector#sources#bookmarks#init() abort "{{{
  function! s:bookmarks_contents(bang) abort "{{{
    let l:contents = bookmarks#get_csv_list()
    return l:contents
  endfunction "}}}

  function! s:bookmarks_info() abort "{{{
    let l:line = getline(".")
    let [l:path, l:pos, l:text] = bookmarks#parse_csv_record(l:line)
    return [l:path, l:pos, l:text]
  endfunction "}}}

  function! s:bookmarks_open() abort "{{{
    let [l:path, l:pos, l:text] = s:bookmarks_info()
    close
    exe 'edit +' . l:pos . ' ' . l:path
  endfunction "}}}

  function! s:bookmarks_split() abort "{{{
    let [l:path, l:pos, l:text] = s:bookmarks_info()
    close
    exe 'split +' . l:pos . ' ' . l:path
  endfunction "}}}

  function! s:bookmarks_vsplit() abort "{{{
    let [l:path, l:pos, l:text] = s:bookmarks_info()
    close
    exe 'vsplit +' . l:pos . ' ' . l:path
  endfunction "}}}

  function! s:bookmarks_tabopen() abort "{{{
    let [l:path, l:pos, l:text] = s:bookmarks_info()
    close
    exe 'tabedit +' . l:pos . ' ' . l:path
  endfunction "}}}

  function! s:bookmarks_delete() abort "{{{
    let [l:path, l:pos, l:text] = s:bookmarks_info()
    call bookmarks#delete(l:path, l:pos)
    call selector#action#reload()
  endfunction "}}}

  let s:bookmarks = {
    \   'name': 'bookmarks',
    \   'contents': function('s:bookmarks_contents'),
    \   'actions': {
    \     'open': function('s:bookmarks_open'),
    \     'split': function('s:bookmarks_split'),
    \     'vsplit': function('s:bookmarks_vsplit'),
    \     'tabopen': function('s:bookmarks_tabopen'),
    \     'delete': function('s:bookmarks_delete'),
    \   },
    \ }
  return s:bookmarks
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
