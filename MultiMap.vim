" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
scriptencoding utf-8
" [Tab] "{{{
noremap [Tab] <Nop>

noremap <silent> [Tab]n :tabnext<CR>
noremap <silent> [Tab]p :tabprevious<CR>
noremap <silent> [Tab]gn :tablast<CR>
noremap <silent> [Tab]gp :tabfirst<CR>

noremap <silent> [Tab]<Space> :tabnext<CR>
noremap <silent> [Tab]<S-Space> :tabprevious<CR>

noremap <silent> [Tab]c :tabclose<CR>
noremap <silent> [Tab]gf <C-W>gF
noremap <silent> [Tab]gf <C-W>gF

noremap <silent> [Tab]<C-]>  <C-]>
noremap <silent> [Tab]g<C-]> g<C-]>

noremap <silent><expr> [Tab]k ':tab help '.expand('<cword>').'<CR>'

noremap <silent> [Tab]m :<C-u>call MoveToNewTab()<CR>
command! MoveToNewTab call MoveToNewTab()
function! MoveToNewTab() "{{{
  tab split
  tabprevious
  if winnr('$') > 1
    close
  elseif bufnr('$') > 1
    buffer #
  endif
  tabnext
endfunction "}}}

"}}}

"[Tag] "{{{
noremap [Tag] <Nop>
"noremap <silent> [Tag]t :<C-U>call JumpTag("tjump")<CR>
noremap <silent><expr> [Tag]t ':tjump '.expand('<cword>').'<CR>'
noremap <silent> [Tag]s :<C-U>tselect<CR>
noremap <silent> [Tag]l :<C-U>tags<CR>
noremap <silent> [Tag]n :<C-U>tn<CR>
noremap <silent> [Tag]p :<C-U>tp<CR>

"noremap <silent> [Tag]pt :<C-U>call JumpTag("ptjump")<CR>
noremap <silent><expr> [Tag]pt ':ptjump '.expand('<cword>').'<CR>'
noremap <silent> [Tag]ps :<C-U>ptselect<CR>
noremap <silent> [Tag]pn :<C-U>ptn<CR>
noremap <silent> [Tag]pp :<C-U>ptp<CR>
"}}}

"[pTag] "{{{
noremap [pTag] <Nop>
"noremap <silent> [pTag]t :<C-U>call JumpTag("ptjump")<CR>
noremap <silent><expr> [pTag]t ':ptjump '.expand('<cword>').'<CR>'
noremap <silent> [pTag]s :<C-U>ptselect<CR>
noremap <silent> [pTag]l :<C-U>tags<CR>
noremap <silent> [pTag]n :<C-U>ptn<CR>
noremap <silent> [pTag]p :<C-U>ptp<CR>
"}}}

"function! JumpTag(kind) abort "{{{
  "let l:cword = expand("<cword>")
  "if len(l:cword)
    "try
      "execute ':' a:kind . ' ' . l:cword
    "catch
      "echo v:throwpoint . "\n" . v:exception
    "endtry
  "else
    "echo "no <cword>"
  "endif
"endfunction "}}}

"MapModeChange"{{{
"let g:MultiMapList = ['', '[Tag]', '[pTag]', '[Tab]', ]
let g:MultiMapList = ['', '[Tag]', '[pTag]', ]
"let g:MultiMapChar = 't'

function! MultiMap() "{{{
  try
    let g:MultiMapChar = get(g:, 'MultiMapChar', 't')

    let l:map = remove(g:MultiMapList, 0)
    call add(g:MultiMapList, l:map)

    if empty(g:MultiMapList[0])
      if hasmapto(g:MultiMapChar)
        execute 'unmap '.g:MultiMapChar
      endif
      echo "No MyMapMode."
    else
      execute 'map <silent> '.g:MultiMapChar.' '.g:MultiMapList[0]
      if get(g:, 'MultiMap_use_unite', 0) is 1 && exists(':Unite') is 2
        let l:mapCommand = ':<C-U>Unite mapping -input='
      else
        let l:mapCommand = ':<C-U>map '
      endif
      execute 'noremap '.g:MultiMapList[0].'? '.l:mapCommand.g:MultiMapList[0].'<CR>'
    endif
  catch
    echo v:throwpoint . "\n" . v:exception
  endtry
endfunction "}}}
command! MultiMap call MultiMap()

function! GetMultiMapMode() "{{{
  return get(g:, 'MultiMapList', [''])[0]
endfunction "}}}
"set statusline+=%{GetMultiMapMode()}

"nnoremap <Leader>t :<C-U>MultiMap<CR>
"}}}

