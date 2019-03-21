scriptencoding utf-8
"-----------------------------------------------------------------------------
"gvimrc"{{{
"$VIMFILES/gvimrc
" source /RepositoryPath/dotfiles/.gvimrc
" let $MYGVIMRC = expand('/RepositoryPath/dotfiles/.gvimrc')
""}}}
" ウインドウに関する設定:{{{
" ウインドウの幅
set columns=999
" ウインドウの高さ
set lines=999

if has('vim_starting')
  augroup gvimEnter
    autocmd!
  augroup END
endif

if g:is_windows
  " ウィンドウを最大化
  if has('vim_starting')
    autocmd gvimEnter GUIEnter * simalt ~x
  else
    simalt ~x
  endif
endif

set guioptions&
"システムメニューを読み込まない。
set guioptions+=M
"メニューバーを表示しない
set guioptions-=m
" メニュー項目の切り離しを無効にする
set guioptions-=t
" ツールバーを非表示
set guioptions-=T
"非GUIのタブページラインを使用
set guioptions-=e
"ポップアップダイアログでなくコンソールダイアログを使う。
set guioptions+=c
"外部コマンドを端末ウィンドウで実行する
set guioptions+=!

" 右スクロールバーを常に表示。
set guioptions-=r
" 垂直分割時のみ右スクロールバー表示
if g:is_windows
  " https://github.com/vim-jp/issues/issues/779
  set guioptions-=R
else
  set guioptions+=R
endif
" 常に左スクロールバーを表示
set guioptions+=l
" 垂直分割されたウィンドウがあるときのみ、左スクロールバーを表示
set guioptions+=L

" 水平スクロールバーを非表示
set guioptions-=b
"水平スクロールバーのサイズをカーソル行の長さに制限する
set guioptions+=h

if has('kaoriya')
  "ウィンドウの枠を消す
  "set guioptions+=C

  function! s:Transparency(bang) "{{{
    augroup Transparency
      autocmd!
    augroup END
    if a:bang == '!'
      set transparency=255
    else
      autocmd Transparency FocusGained * let &transparency=get(g:, 'FocusGaindelTransparency', '230')
      autocmd Transparency FocusLost * let &transparency=get(g:, 'FocusLostTransparency', '150')
      doautocmd FocusGained
    endif
  endfunction "}}}
  "let g:FocusGaindelTransparency = 230
  "let g:FocusLostTransparency = 150

  command! -bang Transparency call s:Transparency('<bang>')
  "autocmd gvimEnter GUIEnter * :Transparency

endif
"}}}
"-----------------------------------------------------------------------------
"画面表示に関する設定"{{{
let g:guiFontList = []
let g:guiFontWideList = []
if g:is_windows
  call add(g:guiFontList, 'MeiryoKe_Gothic:h11:cDEFAULT')
  call add(g:guiFontList, 'MyricaM_M:h12:cDEFAULT')
  call add(g:guiFontList, 'Myrica_M:h12:cDEFAULT')
  call add(g:guiFontList, 'VL_ゴシック:h11:cDEFAULT')
  call add(g:guiFontList, 'MS_Gothic:h10:cSHIFTJIS')
else
  if has("gui_gtk2")
    call add(g:guiFontList, 'VL ゴシック 10')
  endif
endif
function! s:setGuiFont() "{{{
  if !empty(g:guiFontList)
    let &guifont = join(g:guiFontList, ',')
  endif
endfunction "}}}

if has('vim_starting')
  autocmd gvimEnter GUIEnter * call s:setGuiFont()
endif

"set linespace=1
let &ambiwidth = has('kaoriya') ? 'auto' : 'double'

set guicursor& guicursor+=a:blinkon0
set t_vb=

if g:is_windows
  if has('directx') "{{{
    let g:enable_auto_rop = get(g:, 'enable_auto_rop', 0)

    let g:rop = 'type:directx,taamode:1,renmode:3,geom:1,gamma:1.2'
    command! ToggleROP let &rop = empty(&rop) ? g:rop : ''
    nnoremap <Leader>ro :ToggleROP<CR>
    if get(g:, 'enable_auto_rop', 0)
      augroup SetRenderOptions
        autocmd!
      augroup END
      autocmd SetRenderOptions CursorHold,CursorHoldI,FocusLost * let &rop=g:rop
          \|autocmd! SetRenderOptions
    endif
  endif "}}}
endif
"}}}
"-----------------------------------------------------------------------------
" マウスに関する設定:"{{{
"set nomousefocus
"set mousehide
"}}}
"-----------------------------------------------------------------------------
" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
