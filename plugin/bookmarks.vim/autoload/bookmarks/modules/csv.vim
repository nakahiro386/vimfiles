function! s:_vital() abort "{{{
  let l:vital = bookmarks#modules#load('Text.CSV')
  return l:vital
endfunction "}}}

function! bookmarks#modules#csv#parse_file(file) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Text.CSV.parse_file(a:file)
endfunction "}}}

function! bookmarks#modules#csv#dump_file(data, file) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Text.CSV.dump_file(a:data, a:file)
endfunction "}}}

function! bookmarks#modules#csv#dump_record(data) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Text.CSV.dump_record(a:data, a:file)
endfunction "}}}

function! bookmarks#modules#csv#parse_record(csvline) abort "{{{
  let l:vital = s:_vital()
  return l:vital.Text.CSV.parse_record(a:csvline)
endfunction "}}}
