let s:colorscheme = {}

function! selector#sources#colorscheme#init() abort "{{{
  function! s:colorscheme_contents(bang) abort "{{{
    let l:contents = map(split(globpath(&runtimepath, 'colors/*.vim'), '\n'),
      \ 'fnamemodify(v:val, ":t:r")')
    return l:contents
  endfunction "}}}

  function! s:colorscheme_open() abort "{{{
    exe 'color' getline('.')
    close
  endfunction "}}}

  function! s:colorscheme_preview() abort "{{{
    exe 'color' getline('.')
  endfunction "}}}

  let s:colorscheme = {
    \   'name': 'colorscheme',
    \   'contents': function('s:colorscheme_contents'),
    \   'actions': {
    \     'open': function('s:colorscheme_open'),
    \     'preview': function('s:colorscheme_preview'),
    \   },
    \ }
  return s:colorscheme
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
