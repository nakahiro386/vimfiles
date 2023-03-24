let s:sources = {}

function! selector#sources#init() abort "{{{
  if !empty(s:sources)
    return
  endif
  runtime! autoload/selector/sources/*.vim
  for l:fn in filter(split(execute('function /^selector#sources#.\+#init$'), "\n"), 'v:val =~# "^function*"')
    let l:source = call(matchstr(l:fn, '^function\s*\zs.\+\ze('), [])
    let s:sources[l:source.name] = l:source
  endfor
endfunction "}}}

function! selector#sources#get(...) abort "{{{
  if empty(s:sources)
    call selector#sources#init()
  endif
  let l:source = copy(s:sources)
  if !empty(a:000) && selector#util#is_string(a:1)
    let l:name = a:1
    let l:source = get(s:sources, l:name, {})
  endif
  return l:source
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
