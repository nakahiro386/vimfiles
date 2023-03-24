scriptencoding utf-8

function! bookmarks#add()
  if !empty(&l:buftype)
    return
  endif
  let l:list = bookmarks#get_list()

  let l:path = expand('%:p')
  let l:pos = line('.')
  let l:text = getline('.')
  let l:data = [l:path, l:pos, l:text[:g:bookmarks_text_len]]
  call add(l:list, l:data)

  call s:save(l:list, '')
endfunction

function! bookmarks#delete(path, pos)
  let l:list = bookmarks#get_list()
  call filter(l:list, 'v:val[0] !=# a:path && v:val[0]  !=# a:pos')
  call s:save(l:list, '')
endfunction

function! bookmarks#get_list()
  let l:bookmark_file = bookmarks#get_bookmark_file('')

  if !filereadable(l:bookmark_file)
    return []
  endif
  let l:bookmark_list = bookmarks#modules#csv#parse_file(l:bookmark_file)
  return l:bookmark_list
endfunction

function! bookmarks#get_csv_list()
  let l:bookmark_file = bookmarks#get_bookmark_file('')

  if !filereadable(l:bookmark_file)
    return []
  endif
  let l:bookmark_list = readfile(l:bookmark_file)
  return l:bookmark_list
endfunction

function! bookmarks#get_bookmark_file(filename)
  let l:filename = empty(a:filename) ? 'bookmarks.csv' : a:filename
  let l:bookmark_file = expand(s:filepath_join(g:bookmarks_dir, l:filename))
  return l:bookmark_file
endfunction

function! bookmarks#parse_csv_record(csv_record)
  return bookmarks#modules#csv#parse_record(a:csv_record)
endfunction

function! bookmarks#parse_csv_record(csv_record)
  return bookmarks#modules#csv#parse_record(a:csv_record)
endfunction

function! s:save(list, filename)
  let l:bookmark_file = bookmarks#get_bookmark_file(a:filename)
  let l:bookmarks_dir = fnamemodify(l:bookmark_file, ':h')
  if !isdirectory(l:bookmarks_dir)
    call mkdir(l:bookmarks_dir, 'p')
  endif
  call bookmarks#modules#csv#dump_file(a:list, l:bookmark_file)
endfunction

function! s:filepath_join(...) abort "{{{
  return bookmarks#modules#filepath#join(a:000)
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
