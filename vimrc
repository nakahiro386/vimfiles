"-----------------------------------------------------------------------------
"Setting:{{{
"-----------------------------------------------------------------------------
"vimrc"{{{
"$VIMFILES/vimrc
" source /RepositoryPath/dotfiles/.vimrc
" let $MYVIMRC = expand('/RepositoryPath/dotfiles/.vimrc')
""}}}
"Initialization:"{{{
" vim-tiny or vim-small. :h no-eval-feature
if !1 | finish | endif

if &compatible
  set nocompatible
endif

if has('vim_starting') "{{{
  " from vital.vim
  let g:is_unix = has('unix')
  lockvar g:is_unix
  let g:is_windows = has("win32") || has("win64")
  lockvar g:is_windows
  let g:is_android = exists('$ANDRODI_ROOT')
  lockvar g:is_android
  let g:is_msys = !empty($MSYSTEM)
  lockvar g:is_msys
  " Vital.Prelude.set_default()
  function! Set_default(var, val) abort
    if !exists(a:var) || type({a:var}) != type(a:val)
      let {a:var} = a:val
    endif
  endfunction

  " -RMn --servername VIEW --remote-tab-silent --literal 
  let g:is_view = (v:servername ==? 'VIEW') || (get(g:, 'no_plugin_maps', 0) is 1)
  lockvar g:is_view

endif "}}}

if has('gui_running')
  "The system menu "$VIMRUNTIME/menu.vim" is not sourced
  ":h 'go-M'
  set guioptions+=M
endif

if exists('+shellslash')
  set shellslash
endif

if has('vim_starting') "{{{
  let g:sfile_path = expand('<sfile>:p')
  lockvar g:sfile_path
endif "}}}

let s:has_kaoriya = has('kaoriya')

if g:is_windows
  let g:drive_letter = g:sfile_path[0]
endif

augroup MyAutoCmd
  autocmd!
augroup END
let g:messages = []

" Usage: if HasVersion('7.3.693')
function! HasVersion(version) abort "{{{
  " 7.4.237 and later
  " :if has("patch-7.4.248")
  let l:versions = split(a:version, '\.')

  let l:major = str2nr(get(l:versions, 0, '0')) * 100
  let l:minor = str2nr(get(l:versions, 1, '0'))
  let l:patch = get(l:versions, 2, '')

  let l:version = l:major + l:minor
  return v:version > l:version ||
    \ (v:version == l:version && (empty(l:patch) || has('patch' . l:patch)))
  endif
endfunction "}}}

"}}}
"-----------------------------------------------------------------------------
"Encoding:"{{{
set fileformats=unix,dos,mac
if has('vim_starting')
  if !g:is_view || &modifiable
    set fileformat=unix
  endif
  set encoding=utf-8
endif
scriptencoding utf-8

function! Is_cmd() "{{{
  return &shell =~? 'cmd.exe' || &term =~? 'win32'
endfunction "}}}
if Is_cmd()
  set termencoding=cp932
  let g:term_separator='\'
else
  set termencoding=utf-8
  let g:term_separator='/'
endif
let g:rep_path = ':p:gs?[\/]?'.g:term_separator.'?'

let s:fencs = ['ucs-bom', 'utf-8', 'utf-16le', 'euc-jp', 'cp932', 'ucs-2le',
  \ 'ucs-2', 'iso-2022-jp-3', 'euc-jisx0213']
let &fileencodings = join(s:fencs ,',')
if has('guess_encode')
  set fileencodings^=guess
endif
"}}}
"-----------------------------------------------------------------------------
" Environment Property:"{{{
function! Mkdir(path) "{{{
  if !exists("*mkdir")
    call EchoError('Not available mkdir()')
    return 0
  endif
  let l:path = expand(a:path)
  if !isdirectory(l:path)
    return mkdir(l:path, 'p')
  endif
endfunction "}}}
function! ConvEnvPath(path) "{{{
  return fnamemodify(expand(a:path), g:rep_path .
    \ (g:is_windows ? ':s?[\\/]$??:s?:$?:\\?' : ':s?[\/]$??'))
endfunction "}}}

" VIM: "{{{
if has('vim_starting')
  if g:is_windows
    if expand('$HOME') ==? expand('$HOMEDRIVE$HOMEPATH')
      let s:mes = '$HOME is %s. Please check environment variable.'
      call add(g:messages, printf( s:mes, expand("$HOME")))
    endif
  endif

  let $VIMFILES = expand('$HOME/' . (g:is_windows ? 'vimfiles' : '.vim'))
  call Mkdir($VIMFILES)
  let $VIMBUNDLE = expand('$VIMFILES/bundle')
  call Mkdir($VIMBUNDLE)
  let $VIMBUNDLELOCAL = expand('$VIMFILES/bundle_local')
  call Mkdir($VIMBUNDLELOCAL)
  let $VIMDICT = expand('$VIMFILES/dict')
  call Mkdir($VIMDICT)
  if !exists('$MYVIMRC')
    if filereadable(expand('$HOME/.vimrc'))
      let $MYVIMRC = expand('$HOME/.vimrc')
    elseif filereadable(expand('$VIMFILES/vimrc'))
      let $MYVIMRC = expand('$VIMFILES/vimrc')
    elseif filereadable(expand('$VIM/.vimrc'))
      let $MYVIMRC = expand('$VIM/.vimrc')
    endif
  endif
  if !exists('$MYGVIMRC')
    if filereadable(expand('$HOME/.gvimrc'))
      let $MYGVIMRC = expand('$HOME/.gvimrc')
    elseif filereadable(expand('$VIMFILES/gvimrc'))
      let $MYGVIMRC = expand('$VIMFILES/gvimrc')
    elseif filereadable(expand('$VIM/.gvimrc'))
      let $MYGVIMRC = expand('$VIM/.gvimrc')
    endif
  endif
  " if !exists('$LANG')
    " let $LANG = 'ja_JP.UTF-8'
  " endif
endif
"}}}

if has('vim_starting') && g:is_windows
  function! AddPath(list, path) "{{{
    let l:path = ConvEnvPath(a:path)
    if index(a:list, l:path, 0, 1) is -1
      call add(a:list, l:path)
    endif
  endfunction "}}}

  let s:PATH = split(tr($PATH, '/', '\'), ';')
  let s:PATH = map(s:PATH, 'ConvEnvPath(v:val)')

  let s:path_list = [ConvEnvPath($VIM)]
  call map(s:PATH, 'AddPath(s:path_list, v:val)')

  " ruby puts RUBY_VERSION
  " perl VIM::Msg($])
  " py print(sys.version)
  " py3 print(sys.version)
  " lua print(_VERSION)
  " if !exists('$RUBYOPT')
    " let $RUBYOPT='-EUTF-8'
  " endif

  let $PATH = join(s:path_list, (g:is_windows ? ';' : ':'))
  delfunction AddPath
  unlet s:path_list
  unlet s:PATH

  if !exists('$LYNX_CFG') || executable('lynx')
    let s:lynx_cfg = expand('~/lynx.cfg')
    if filereadable(s:lynx_cfg)
      let $LYNX_CFG = ConvEnvPath(s:lynx_cfg)
    else
      call add(g:messages, s:lynx_cfg)
    endif
  endif

endif

"}}}
"-----------------------------------------------------------------------------
"Global Variabl:"{{{
let g:memo_dir = expand('$HOME/Documents/memo/')
if isdirectory(expand('$HOME/.bk'))
  let g:backup_dir =expand('$HOME/.bk')
else
  let g:backup_dir=expand('$VIMFILES/tmp/bk')
endif

"Windows:"{{{
if g:is_windows
  "WordやExcelのファイルを読込専用で開く
  "http://sei.qee.jp/docs/program/hta/sample/open_readonly.html
  "https://gist.github.com/satob/263262
  let g:office_readonly_path = expand('$HOME/bin/office_readonly.vbs')
  let g:office_readonly_extensions = join([
    \ '*.xls', '*.xlsx', '*.xlsm', '*.xlsb',
    \ '*.doc', '*.docx',
    \ '*.ppt', '*.pptx',
    \ '*.mpp',
    \ '*.png', '*.jpg', '*.gif',
    \ '*.pdf'
    \ ], ',')

  "craftware
  "https://sites.google.com/site/craftware/
  " CraftDrop
  let g:cdrop = expand('$HOME/bin/cdrop/cdrop.exe')

  let g:ipmsg_path = expand('$LOCALAPPDATA/IPMsg/ipmsg.exe')
  if !executable(g:ipmsg_path)
    let g:ipmsg_path = expand('$PROGRAMFILES/IPMsg/ipmsg.exe')
  endif

endif
"}}}

"}}}
"-----------------------------------------------------------------------------
"Misc:{{{

set clipboard&
if g:is_windows || has('gui_running') || has('clipboard')
  set clipboard=unnamed
  if has('unnamedplus')
    set clipboard+=unnamedplus
  endif
  "set clipboard+=html
endif

set shortmess&
set shortmess+=o
set shortmess+=n
set shortmess+=m
set shortmess+=r
set shortmess+=w
set shortmess+=x
set shortmess+=s
set shortmess+=I

set helplang=ja,en
set keywordprg=:help

" 折り返された行の表示に行番号表示領域を使う
"set cpoptions+=n
" readonlyを上書きしない
set cpoptions+=W

if has('vim_starting')
  set noundofile
endif
if &undofile
  set undodir=$VIMFILES/tmp/undodir
  call Mkdir(&undodir)
endif
set undoreload=10000

set history=100
set updatetime=1000
if has('vim_starting')
  let g:update_time = &updatetime
  lockvar g:update_time
endif
set timeout timeoutlen=3000 ttimeoutlen=100

let g:mapleader = "[Space]"
let g:maplocalleader = "[Comma]"

"let g:did_install_default_menus = 1
let g:did_install_syntax_menu = 1

"}}}
"-----------------------------------------------------------------------------
"Backup:"{{{
set backup writebackup backupcopy=yes
let &backupdir = g:backup_dir
set backupskip&
if g:is_windows
  set backupskip+=ipmsg.log,無題.txt,新しいテキスト\ ドキュメント.txt
  execute 'set backupskip+='.expand('$MYVIMRC')
  execute 'set backupskip+='.expand('$MYGVIMRC')
  if exists('g:memo_dir')
    let &backupskip .= ',' . g:memo_dir . '*'
  endif
endif
let &backupskip .= ',' . g:backup_dir . '/*'

function! s:SetBackupDir() "{{{
  if !&backup || get(b:, 'backup_skip', 0)
    return
  endif
  let l:fname = expand('%:p')
  let l:dir = g:backup_dir.'/'.fnamemodify(l:fname, ':gs?[:\/]?_?')
  call Mkdir(l:dir)
  let &backupdir = l:dir
  let l:ext_time = strftime("%Y%m%d%H%M%S", localtime())
  let &backupext = '_'.l:ext_time.'.'.fnamemodify(l:fname, ':e')
endfunction "}}}
augroup MyBackup "{{{
  autocmd!
  for target in split(&backupskip, ',')
    execute ':autocmd BufWritePre '.target.' let b:backup_skip = 1'
  endfor
  unlet target
  autocmd BufWritePre * call s:SetBackupDir()
augroup END "}}}
"}}}
"-----------------------------------------------------------------------------
"File:{{{
set swapfile
set directory=$VIMFILES/tmp/swap//
call Mkdir(&directory)
set updatecount=100
augroup MyAutoCmd
  autocmd WinEnter * if (&l:readonly || !&l:modifiable || !empty(&l:buftype)) && &l:swapfile | setl noswapfile | endif
  let s:path = ['$VIMFILES/tmp/**', g:backup_dir.'/**', 'ipmsg.log']
  exe printf('autocmd BufRead %s if &swapfile | setl noswapfile | endif', join(s:path, ','))
  unlet s:path
augroup END

"TODO noautoread時にw11を回避する方法
set autoread
set hidden

set diffopt=filler,vertical
set browsedir=buffer
"}}}
"-----------------------------------------------------------------------------
"Viminfo View Session:"{{{

"viminfo"{{{
if g:is_view
  set viminfo=
else
  set viminfo&
  set viminfo='0,<10,s1,h
  set viminfo+=f0
  "set viminfo+=f1
  set viminfo+=/10
  set viminfo+=@5
  set viminfo+=%
  set viminfo+=!
  set viminfo+=c
  if g:is_windows
    set viminfo+=rA:,rB:,rX:,rS:,rT:,rQ:,rU:,rJ:
  endif
  set viminfo+=n$VIMFILES/tmp/.viminfo
endif

"}}}

set viewdir=$VIMFILES/tmp/view
call Mkdir(&viewdir)
set viewoptions=folds,cursor,slash,unix
"set sessionoptions=blank,folds,help,slash,winpos,winsize,tabpages
set sessionoptions=blank,folds,slash,unix,tabpages

"}}}
"-----------------------------------------------------------------------------
"Edit:{{{
set expandtab
set tabstop=4
set shiftwidth=4
if HasVersion('7.3.693')
  set softtabstop=-1
endif

set autoindent
set smartindent
set copyindent
set preserveindent

set shiftround
set whichwrap=b,s,<,>,~
set virtualedit=block
set nrformats=hex

"~{motion}を有効化
set tildeop

set backspace=indent,eol,start
set showmatch

set iminsert=0 imsearch=-1

augroup MyAutoCmd
  autocmd BufRead * if &readonly && &modifiable | setlocal nomodifiable | endif
  let s:path = ['$VIMRUNTIME/**', g:backup_dir.'/**', '$VIMBUNDLE/**', 'ipmsg.log', ]
  exe printf('autocmd BufRead %s setlocal nomodifiable', join(s:path, ','))
  unlet s:path
  autocmd InsertLeave * if &paste | set nopaste | endif
augroup END

"}}}
"-----------------------------------------------------------------------------
"Search:{{{
set ignorecase
set nosmartcase
set nowrapscan
set incsearch
set hlsearch
if executable('jvgrep')
  "let $JVGREP_OUTPUT_ENCODING='utf-8'
  set grepprg=jvgrep\ -in8
elseif g:is_windows
  set grepprg=internal
endif

" tagsファイルは親ディレクトリを辿って探す
set tags=./tags;

set matchpairs+=<:>
if &encoding ==? 'utf-8' && !g:is_msys
  set matchpairs+=（:）
  set matchpairs+=「:」
  set matchpairs+=【:】
endif

"}}}
"-----------------------------------------------------------------------------
"Complete:"{{{
set complete&
set complete+=d
set complete+=k
set complete+=kspell
set completeopt=menuone
set wildmenu
set wildmode=longest,full
set wildoptions=tagfile
set showfulltag
set infercase
set pumheight=18
if HasVersion('7.4.92')
  set spelllang& spelllang+=cjk
endif

"}}}
"-----------------------------------------------------------------------------
"Display:{{{
set number
set ruler
set display=lastline,uhex

set cmdheight=2
set showcmd
set showmode
set title
let &titleold='Thanks for flying Vim'

set nowrap
if &cpoptions =~# 'n'
  let g:showbreak_mark = '@'
  function! GetNumberWidth()
    return &numberwidth > len(line('$')) ? &numberwidth : len(line('$'))
  endfunction
  autocmd MyAutoCmd BufWinEnter * if &cpoptions =~# 'n'
    \|  let &showbreak = repeat(g:showbreak_mark, GetNumberWidth()).' '
    \| endif
endif

if !has('gui_running')
  set ambiwidth=double
endif

set cmdwinheight=1
set previewheight=20

set splitbelow
set splitright
set switchbuf=useopen,usetab,newtab,split
set scrolljump=1
set scrolloff=3
"set sidescrolloff=5

set nostartofline  "カーソル、バッファ移動時にカーソル位置を保持

set equalalways

set synmaxcol=1000
set colorcolumn=+1

if has('gui_running') && &encoding ==? 'utf-8'
  "echo char2nr('↵', 1)
  "echo nr2char(8629, 1)
  set listchars=tab:>\ ,extends:>,precedes:<,eol:↵,trail:-,nbsp:%
else
  set listchars=tab:>\ ,precedes:<,extends:>,eol:\ ,trail:-,nbsp:%
endif
set list

"set fillchars=stlnc:_,vert:+
set fillchars=

set lazyredraw

" autocmd MyAutoCmd VimEnter * if !argc() | tab ball|tabfirst |endif

"}}}
"-----------------------------------------------------------------------------
"Terminal:"{{{
set novisualbell
set t_vb=
if !has('gui_running')
  if has('mouse')
    set ttymouse=xterm2
  endif
  execute 'set <xUp>='   ."\<Esc>OA"
  execute 'set <xDown>=' ."\<Esc>OB"
  execute 'set <xRight>='."\<Esc>OC"
  execute 'set <xLeft>=' ."\<Esc>OD"
  execute 'set <S-Up>='   .";2A"
  execute 'set <S-Down>=' .";2B"
  execute 'set <S-Right>='.";2C"
  execute 'set <S-Left>=' .";2D"
  execute 'set <xF1>='   ."\<Esc>OP"
  execute 'set <xF2>='   ."\<Esc>OQ"
  execute 'set <xF3>='   ."\<Esc>OR"
  execute 'set <xF4>='   ."\<Esc>OS"
  execute 'set <xHome>=' ."\<Esc>OH"
  execute 'set <xEnd>='  ."\<Esc>OF"
  if &term =~? "^xterm" || &term =~? "^.*256.*$"
    set t_Co=256
  else
    set t_Co=16
  endif
  " " http://ttssh2.sourceforge.jp/manual/ja/usage/tips/vim.html
  " set t_SI&
  " set t_EI&
  " let &t_SI .= "\e[5 q"
  " let &t_EI .= "\e[2 q"
endif
"}}}
"-----------------------------------------------------------------------------
"Line Function:"{{{
function! GetShortPath(path,wordlen,minlen) "{{{
  if empty(a:path)
    return a:path
  endif
  return GetShortPath2(fnamemodify(a:path, ':p:~'), a:wordlen, a:minlen)
endfunction "}}}
function! GetShortPath2(path,wordlen,minlen) "{{{
  let l:path = a:path
  if strwidth(l:path) >= a:minlen
    let l:list = split(l:path, '/')
    call map(l:list, printf('join(split(v:val, "\\zs")[0:%s], "")', a:wordlen - 1 ))
    let l:path = join(l:list, '/')
  endif
  return l:path
endfunction "}}}

function! GetShortFileName(name, maxlen) "{{{
  let l:name = a:name
  if strchars(l:name) > (a:maxlen + 1)
    let l:name = l:name[:a:maxlen].'…'
  endif
  return l:name
endfunction "}}}
function! GetShortFileName2(name, len) "{{{
  let l:name = a:name
  if strchars(l:name) > ((a:len * 2) + 1)
    let l:names = split(l:name, '\zs')
    let l:name = join(l:names[:(a:len)] + ['…'] + l:names[-(a:len):], '')
  endif
  return l:name
endfunction "}}}

function! GetFileEncoding() "{{{
  return empty(&l:fileencoding) ? '__' : &l:fileencoding
endfunction "}}}

function! RelativePath(src, dest) "{{{
  let l:src = split(fnamemodify(a:src, ':p'), '/')
  let l:srcLen = len(l:src)
  let l:dest = split(fnamemodify(a:dest, ':p'), '/')
  let l:destLen = len(l:dest)
  let l:len = l:srcLen > l:destLen ? l:srcLen : l:destLen

  let l:ret = []
  let l:i = 0
  while l:i < l:len

    let l:s = get(l:src, l:i, '')
    let l:d = get(l:dest, l:i, '')

    if l:s !=? l:d
      if l:i == 0
        let l:ret = l:dest
        break
      endif
      if empty(l:s)
        let l:ret = l:dest[(l:i):]
        break
      else
        let l:ret = l:dest
        break
      endif
    endif
    let l:i += 1
  endwhile
  return (!g:is_windows ? '/' : '') . join(l:ret, '/')
endfunction "}}}

function! BufPwd()
  return get(w:, 'pwd', getcwd())
endfunction
autocmd MyAutoCmd WinEnter,WinLeave,FocusLost * let w:pwd = getcwd()

let g:defaultBufName = '無名'
function! Bufpath() "{{{
  if !exists('b:head') || !exists('b:tail')
    let b:head = empty(&buftype) ? expand('%:p:h') : ''
    let b:tail = expand('%:t')
    let b:tail = empty(b:tail) ? get(g:, 'defaultBufName', '') : b:tail
  endif
  if empty(b:head) || b:head ==? fnamemodify(BufPwd(), ':p:h')
    let l:bufpath = b:tail
  else
    let l:bufpath = GetShortPath2(RelativePath(BufPwd(), b:head ), 3, 30). (b:head =~ '.*/$' ? '' : '/').b:tail
  endif
  return l:bufpath
endfunction "}}}
function! Bufpath() "{{{
  let l:path = empty(@%) ? get(g:, 'defaultBufName', '') : @%
  return GetShortPath2(l:path, 3, 30)
endfunction "}}}
function! UnBufpath() "{{{
  if exists('b:head')
    unlet b:head
  endif
  if exists('b:tail')
    unlet b:tail
  endif
endfunction "}}}
autocmd MyAutoCmd BufWritePost * call UnBufpath()

"}}}
"-----------------------------------------------------------------------------
"Titlestring:{{{
let &g:titlestring=''
  \ . '%t%( %M%R%)'
  \ . '%( (%{&l:buftype==# "" ? expand("%:~:h") : &l:buftype})%)'
  \ . '%( %a%) - %{v:servername}'
"}}}
"-----------------------------------------------------------------------------
"Statusline:{{{
set laststatus=2

function! StatuslineSuffix() "{{{
  let l:ret =''
  let l:ret.='['
  let l:ret.='%{(empty(&l:filetype) ?"__":&l:filetype)}'
  let l:ret.=':'
  let l:ret.='%#Error#%{&l:filetype==?"dosbatch" && &l:fileencoding!=?"cp932"?GetFileEncoding():""}%*'
  let l:ret.='%{&l:filetype!=?"dosbatch" || &l:fileencoding==?"cp932"?GetFileEncoding():""}'
  let l:ret.='%{(&l:bomb?"  BOM":"")}'
  let l:ret.=':'
  let l:ret.='%{toupper(&l:fileformat[0])}'
  let l:ret.=']'
  let l:ret.='%{&l:swapfile?"[S]":""}'
  let l:ret.='%#Error#%{&l:swapfile?"":"[ ]"}%*'
  return l:ret
endfunction "}}}
function! StatusLineBufNum() "{{{
  return '%#StatusLineBufNum#[%n]%*'
endfunction "}}}

let s:dict = {
  \   'n'  : ['NORMAL','%#StatusLineModeMsgNO#'],
  \   'i'  : ['INSERT','%#StatusLineModeMsgIN#'],
  \   'c'  : ['C-LINE','%#StatusLineModeMsgCL#'],
  \   'R'  : ['REPLACE','%#StatusLineModeMsgRE#'],
  \   'Rv' : ['R-VIRTUAL','%#StatusLineModeMsgRV#'],
  \   'v'  : ['VISUAL','%#StatusLineModeMsgVI#'],
  \   'V'  : ['V-LINE','%#StatusLineModeMsgVL#'],
  \   "\<C-v>" : ['V-BLOCK','%#StatusLineModeMsgVB#'],
  \   's'  : ['SELECT','%#StatusLineModeMsgSE#'],
  \   "\<C-s>" : ['S-BLOCK','%#StatusLineModeMsgSB#'],
  \ }
function! StatuslineGetMode() "{{{
  let l:ret = ['', '', '']
  let l:mode = mode('1')
  let l:temp = get(s:dict, l:mode, [l:mode])
  let l:ret[1] = '['.l:temp[0].']'
  if len(l:temp) is 2
    let l:ret[0] = l:temp[1]
    let l:ret[2] = '%*'
  endif
  return l:ret[0].Current(l:ret[1], '').l:ret[2]
endfunction "}}}
function! Current(str1, str2) "{{{
  return printf('%%{(winnr() is '. winnr() .') ? "%S":"%S"}', a:str1, a:str2)
endfunction "}}}
function! MyStatusline() "{{{
  "MEMO %{actual_curbuf}⇒本当のカレントバッファで関数 'bufnr()' が返す値
  let l:ret =' '
  let l:ret.=StatusLineBufNum()
  let l:ret.='%#Wildmenu#'
  let l:ret.='[%{GetShortPath(BufPwd(),4,20)}]'
  let l:ret.='%*'
  let l:ret.='[%{Bufpath()}]'
  " let l:ret.='[%{GetShortPath2(@%,3,30)}]'
  let l:ret.='%#Error#%h%w%q%r%m%*'
  let l:ret.=StatuslineGetMode()
  let l:ret.=' '
  let l:ret.='%<'
  let l:ret.='%='
  let l:ret.='%#Todo#'
  let l:ret.=Current(exists("*IMStatus") ? IMStatus('[日本語固定]') : '' , '')
  if exists("*CapsLockStatusline")
    let l:ret.='%{toupper(CapsLockStatusline())}'
  endif
  let l:ret.='%*'
  let l:ret.='%{exists("*GetMultiMapMode")?GetMultiMapMode():""}'
  let l:ret.='%#Search#'
  let l:ret.='%{exists("*anzu#search_status")?anzu#search_status():""}'
  let l:ret.='%*'
  let l:ret.=' '
  let l:ret.=StatuslineSuffix()
  return l:ret
endfunction "}}}
set statusline=%!MyStatusline()

"}}}
"-----------------------------------------------------------------------------
"Tabline:"{{{
set showtabline=2
set guitabtooltip=%h%w%q%{fnamemodify(bufname('%'),':p')}

"GuiTabLabel"{{{
function! GuiTabLabel() "{{{
  let l:label = ''

  let l:fname = fnamemodify(bufname("%"), ':p:t')
  if empty(l:fname)
    let l:fdir = ''
    let l:fname = get(g:, 'defaultBufName', '')
  else
    let l:fdir = GetShortPath(bufname("%"), 2, 0)
    let l:fname = GetShortFileName(l:fname, 12)
  endif
  let l:label .= l:fdir . l:fname

  let l:wincount = tabpagewinnr(v:lnum, '$')
  let l:label .= (l:wincount > 1) ? '[' . l:wincount . ']' : ''

  return l:label
endfunction "}}}

set guitablabel=%N\ %h%w%q%{GuiTabLabel()}%m%r
"}}}

"tabline"{{{
"'tabline'を活用してみた - LeafCage備忘録
"http://d.hatena.ne.jp/leafcage/20120214/1329183521
let g:TabLineSep = (has('gui_running') ? ' | ' : '  ') "'┆¦|⋮'

let s:date_string = '['.strftime("%Y/%m/%d(%a)").']'
function! TabLine() "{{{
  let l:titles = map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
  let l:sep = '%#TabLineSep#' . get(g:, 'TabLineSep', ' ')
  let l:tabpages = ' ' . join(l:titles, l:sep) . l:sep . '%#TabLineFill#%T'
  let l:info = '%#TabLineInfo#'

  "カレントディレクトリ
  if !g:is_android
    let l:colors_name = get(g:, 'colors_name', '')
    let l:info .= s:date_string
    let l:info .= empty(l:colors_name) ? '' : '['.l:colors_name.']'
    if !empty(&guifont)
      let l:info .= '['
      if g:is_windows
        let l:info .= matchstr(&guifont, ':\zsh[0-9.]\+')
      else
        let l:info .= matchstr(&guifont, '\s\+\zs[0-9.]\+')
      endif
      if has('directx')
        let l:info .= empty(&rop) ? '' : ':DW'
      endif
      let l:info .= ']'
    endif
  endif

  return l:tabpages . '%=' . info  " タブリストを左に、情報を右に表示
endfunction "}}}

function! s:tabpage_label(tabpagenr) "{{{
  " タブページ番号の設定
  let l:tabbagenr = '%'.a:tabpagenr.'T'

  " カレントタブページかどうかでハイライトを切り替える
  let l:high_start = a:tabpagenr is tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
  let l:high_end = '%T%#TabLineFill#'

  " タブページ内のバッファのリスト
  let l:bufnrs = tabpagebuflist(a:tabpagenr)
  let l:curbufnr = l:bufnrs[tabpagewinnr(a:tabpagenr) - 1]
  let l:buftype = getbufvar(l:curbufnr, "&buftype")

  let l:prefix = ''
  let l:fname = ''
  let l:suffix = ''

  "prefix
  let l:prefix .= '%#TabLineNo#'
  let l:prefix .= '[' . a:tabpagenr . ']'

  let l:prefix .= l:high_start

  if !empty(l:buftype) && l:buftype !=? 'nofile' && l:buftype !=? 'nowrite'
    let l:prefix .= '['.l:buftype.']'
  endif

  "suffix
  if empty(l:buftype)
    let l:mod  = getbufvar(l:curbufnr, "&modified")   ? '+' : ''
    let l:mod .= getbufvar(l:curbufnr, "&modifiable") ? ''  : '-'
    let l:mod .= getbufvar(l:curbufnr, "&readonly") ? 'R'  : ''
    let l:suffix .= empty(l:mod) ? '' : '%#TabLineMod#['.l:mod.']'
  endif

  "fname
  let l:def = fnamemodify(bufname(l:curbufnr), ':t')
  let l:fname = gettabvar(a:tabpagenr, 'tabname', l:def)
  if !empty(l:fname)
    let l:fname = GetShortFileName2(l:fname, 6)
  else
    let l:fname = get(g:, 'defaultBufName', '')
  endif
  let l:no = len(l:bufnrs) > 1 ? ' [' . len(l:bufnrs) . ']' : ''

  let l:label = l:prefix . l:fname . l:no . l:suffix

  return l:tabbagenr . l:high_start . l:label . l:high_end
endfunction "}}}
command! -nargs=? Tabname exe empty(<q-args>)
  \ ? exists('t:tabname') ? 'unlet t:tabname' : 'echo "t:tabname dose not exists."'
  \ : 'let t:tabname = <q-args>'

set tabline=%!TabLine()
"}}}

"}}}
"-----------------------------------------------------------------------------
"Fold:{{{
let &foldcolumn = (g:is_android ? 0 : 1)
set foldlevel=0
set foldlevelstart=0
set foldmethod=marker
"set foldtext=MyFoldText(78)
set foldtext=MyFoldText(0)
set foldnestmax=8

function! MyFoldText(width) "{{{
  let l:prefix = ''
  let l:body = ''
  let l:suffix = '＠'
  let l:MyFoldText = ''
  let l:suffixMargin = (&textwidth is 0) ? a:width : &textwidth

  "prefix"{{{
  if v:foldlevel > 1
    let l:prefix .= '+'
    if v:foldlevel > 2
      let l:prefix .= repeat('-', v:foldlevel - 2)
    endif
  endif
  "}}}
  "body"{{{
  let l:body = getline(v:foldstart)
  if !empty(&foldmethod)
    let l:body = substitute(l:body, split(&foldmarker, ',')[0], '', 'g')
  endif
  if !empty(&commentstring)
    let l:body = substitute(l:body, split(&commentstring, '%s')[0], '', 'g')
  endif
  let l:body = substitute(l:body, '\v^\s+', '', 'g')
  "}}}
  "suffix"{{{
  let l:LineCount = (v:foldend - v:foldstart + 1) . ' L'
  let l:Level = 'Lv.'.v:foldlevel
  let l:suffix .= '[' . l:LineCount . ']'
  let l:suffix .= '[' . l:Level . ']'
  "}}}

  let l:MyFoldText .= l:prefix
  let l:MyFoldText .= l:body
  if strdisplaywidth(l:MyFoldText) < l:suffixMargin
    let l:count = l:suffixMargin - strdisplaywidth(l:MyFoldText . l:suffix)
    let l:MyFoldText .= repeat(' ', l:count)
  else
    let l:MyFoldText .= '   '
  endif
  let l:MyFoldText .= l:suffix
  return l:MyFoldText

endfunction "}}}

"}}}
"-----------------------------------------------------------------------------
"Balloon:"{{{
" function! MyBalloonExpr()
  " return 'Cursor is at line ' . v:beval_lnum .
      " \', column ' . v:beval_col .
      " \ ' of file ' .  bufname(v:beval_bufnr) .
      " \ ' on word "' . v:beval_text . '"'
" endfunction
" set bexpr=MyBalloonExpr()
"if has('gui_running')
  "set ballooneval
  "set balloondelay=1000
"endif
"}}}
"-----------------------------------------------------------------------------
"Mouse:"{{{
if g:is_windows || has('gui_running')
  set mouse=a
endif
set mousemodel=extend
"}}}
"-----------------------------------------------------------------------------
"}}}
"-----------------------------------------------------------------------------
"Key Mapping:{{{

" h :map-<special>
" h :map-<script>

"Disabled"{{{
noremap  s       <Nop>
noremap  gs      <Nop>
noremap  S       <Nop>
noremap  Q       <Nop>
" noremap  \\      <Nop>
noremap  ZZ      <Nop>
noremap  ZQ      <Nop>
noremap  gQ      <Nop>
noremap  ,       <Nop>
noremap  <Space> <Nop>
noremap  <F1>    <Nop>
noremap! <F1>    <Nop>
noremap! <C-@>   <Nop>
" noremap  <C-z>   <Nop>
" noremap! <C-z>   <Nop>
"}}}

"[Prefix]"{{{
"[Space]{{{
noremap [Space] <Nop>
map <Space> [Space]
nnoremap <expr> <Leader>?<CR> ':<C-u>Mapping ' . g:mapleader . '<CR>'

noremap! [CSpace] <Nop>
map! <C-Space> [CSpace]
inoremap <silent> [CSpace]? <C-o>:Mapping [CSpace]<CR>
"}}}

"[Comma]"{{{
noremap [Comma] <Nop>
map , [Comma]
nnoremap <expr> <LocalLeader>? ':<C-u>Mapping ' . g:maplocalleader .'<CR>'
"}}}

"[C-S-Space]{{{
noremap [CS-Space] <Nop>
map <C-S-Space> [CS-Space]
nnoremap <silent> [CS-Space]? :<C-u>Mapping [CS-Space]<CR>
"}}}

"[Plug]{{{
noremap [Plug] <Nop>
inoremap [Plug] <Nop>
cnoremap [Plug] <Nop>
map <S-Space> [Plug]
imap <S-Space> [Plug]
cmap <S-Space> [Plug]
map <Leader>p [Plug]
nnoremap <silent> [Plug]? :Mapping [Plug]<CR>
"}}}
"}}}

"command-line window{{{
noremap : ;
if g:is_android
  noremap ; :
  noremap q; q:
  noremap <Leader>; q:
else
  function! Save_window_value()
    let g:cword = expand('<cword>')
    let g:buffer_name = expand('%')
  endfunction
  noremap ; :<C-u>call Save_window_value()<CR>q:
  vnoremap ; q:
  noremap q; :
  noremap <Leader>; :
endif

"Vim-users.jp - Hack #161: Command-line windowを使いこなす
"http://vim-users.jp/2010/07/hack161/
function! s:Init_cmdwin() "{{{
  "Option"{{{
  "Global Option
  let b:laststatus = &laststatus
  set laststatus=0
  let b:cmdheight = &cmdheight
  let &cmdheight = b:cmdheight - 1
  let b:ruler = &ruler
  set noruler
  "local to the current buffer or window
  setlocal nonumber
  "setlocal norelativenumber
  "setlocal colorcolumn&
  setlocal textwidth=0
  setlocal wrapmargin=0
  setlocal foldcolumn=0
  setlocal nofoldenable
  "  setlocal nobuflisted
  "highlight
  "let b:ModeMsgHl = 'highlight ' . s:GetHighlight('ModeMsg')
  "highlight ModeMsg guibg=lightgreen guifg=black
  "}}}

  "buffer mapping"{{{
  nnoremap <silent> <buffer> q :<C-u>quit<CR>
  nnoremap <silent> <buffer> Q :<C-u>quit<CR>
  nnoremap <silent> <buffer> <Tab> :<C-u>quit<CR>
  if g:is_windows || has('gui_running')
    nnoremap <silent> <buffer> <Esc> :<C-u>quit<CR>
  else
    nnoremap <silent> <buffer> <Esc><Esc> :<C-u>quit<CR>
  endif
  nnoremap <buffer> / /\v
  nmap <buffer> ; <Esc>q;

  nnoremap <buffer> <S-Up> <C-w>+
  nnoremap <buffer> <S-Down> <C-w>-
  nnoremap <buffer> <S-Left> 1<C-w>_
  exe 'nnoremap <buffer> <S-Right> '.(&history + 1).'<C-w>_ggG'

  "insert
  inoremap <buffer> jj <Esc>j
  inoremap <buffer> kk <Esc>k
  inoremap <buffer> <Down> <Esc><Down>
  inoremap <buffer> <Up> <Esc><Up>
  imap <buffer> ;; <Esc>;
  imap <buffer> <TAB> <C-n>
  if expand('<afile>') == ':' && get(s:, 'installed_vim_ambicmd', 0)
    inoremap <buffer> <expr> <Space> ambicmd#expand("\<Space>")
    inoremap <buffer> <expr> <CR> (pumvisible() ? "\<C-y>" : "") . ambicmd#expand("\<CR>")
  else
    inoremap <buffer> <expr> <CR> (pumvisible() ? "\<C-y>" : "") . "\<CR>"
  endif
  inoremap <buffer> <expr> <C-h> (pumvisible() ? "\<C-y>" : "") . "\<C-h>"
  inoremap <buffer> <expr> <BS>  (pumvisible() ? "\<C-y>" : "") . "\<C-h>"
  inoremap <buffer> <C-x><C-n> <C-n>
  inoremap <buffer> <C-x><C-p> <C-p>
  if exists('g:cword')
    inoremap <buffer> <C-r><C-w> <C-r>=g:cword<CR>
  endif
  if exists('g:buffer_name')
    inoremap <buffer> <C-r>% <C-r>=g:buffer_name<CR>
  endif
  "}}}

  execute "normal! ".&cmdwinheight."\<C-W>_"
  startinsert!
endfunction "}}}
function! s:Leave_cmdwin() "{{{
  "Restore Global Option
  let &ruler = b:ruler
  let &laststatus = b:laststatus
  let &cmdheight = b:cmdheight
  unlet b:ruler
  unlet b:laststatus
  unlet b:cmdheight
  if exists('g:cword')
    unlet g:cword
  endif
  if exists('g:buffer_name')
    unlet g:buffer_name
  endif
  "highlight clear ModeMsg
  "silent exec b:ModeMsgHl
endfunction "}}}
augroup MyCmdWin "{{{
  autocmd!
  autocmd CmdwinEnter * call s:Init_cmdwin()
  autocmd CmdwinLeave * call s:Leave_cmdwin()
augroup END "}}}
"}}}

"registers"{{{

noremap Y y$
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
nnoremap <silent> y% :<C-u>%y<CR>
nnoremap <silent> d% :<C-u>%d _<CR>

noremap <Del> "xx
noremap x "xx
noremap X "xD

" nnoremap gy my"yyy"ypg`y
" nnoremap gY my"yyy"yPg`y
" xnoremap gy "yy"ypgv
" xnoremap gY "yy"yPgv

" nnoremap <M-Up> kV"yd"ypk
" nnoremap <M-Down> V"yd"yp

nnoremap d "dd
vnoremap d "dd
noremap D "dD

nnoremap c "cc
vnoremap c "cc
noremap C "cC

nnoremap dp "dp
nnoremap dP "dP
nnoremap cp "cp
nnoremap cP "cP
"}}}

"insert command-line"{{{
if g:is_windows || (g:is_unix && has('gui_running'))
  noremap! <C-v> <C-r>*
  noremap! <M-v> <C-r>*
endif

noremap! <C-k> <Del>
inoremap <C-f> <C-o>f
inoremap <C-Tab> <C-q><Tab>
inoremap <C-u> <C-g>u<C-u>
inoremap <C-w>  <C-g>u<C-w>
"inoremap [CSpace]da <C-R>=strftime('%Y/%m/%d')<CR>
"inoremap [CSpace]ti <C-R>=strftime('%H:%M:%S')<CR>
"inoremap [CSpace]dt <C-R>=strftime('%Y/%m/%d %H:%M:%S')<CR>
"}}}

"Visual"{{{
"2009/11/25: Hack #104: Visual mode で選択したテキストを検索する
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v,'\/'),"\n",'\\n','g')<CR><CR>

if HasVersion('7.4.754')
  vnoremap <c-a> <c-a>gv
  vnoremap <c-x> <c-x>gv
  vnoremap g<c-a> g<c-a>gv
  vnoremap g<c-x> g<c-x>gv
endif

"}}}

"indent"{{{
" nnoremap > >>
" nnoremap < <<
vnoremap > >gv
vnoremap < <gv
vmap <Tab> >
vmap <S-Tab> <
"}}}

"save{{{
" 起動中はhas('browse')がgvimrcでも1にならない。
nnoremap <C-S> :<C-u>execute (has('browse') ? 'browse ' : '' ) . 'saveas'<CR>
nnoremap <Leader>wr :<C-U>update<CR>
nnoremap <Leader>WR :<C-U>update!<CR>
"}}}

"new"{{{
nnoremap <silent> <C-w>n :<C-u>vnew<CR>
nnoremap <silent> <C-w><C-n> :<C-u>new<CR>
nnoremap <silent> <C-w>N :<C-u>new<CR>
"}}}

"move"{{{
noremap k gk
noremap j gj
noremap gk k
noremap gj j
nnoremap <silent> sh :<C-u>call <SID>SmartHome()<CR>
vnoremap sh ^
nnoremap sl g$
vnoremap sl g_
onoremap sl g_
vnoremap sa oggoG
function! s:SmartHome() "{{{
  let l:colPos = col(".")
  normal! ^
  if (l:colPos != 1) && (l:colPos == col("."))
    normal! 0
  endif
endfunction "}}}
nnoremap <silent> <c-j> :<C-u>call <SID>MoveChange('g;')<CR>
nnoremap <silent> <c-k> :<C-u>call <SID>MoveChange('g,')<CR>
function! s:MoveChange(cmd) "{{{
  try
    execute 'normal! '.a:cmd
  catch /^Vim\%((\a\+)\)\=:E66[2-4]/
    redraw
    call EchoWarning(v:exception)
  catch /^Vim\%((\a\+)\)\=:E19/
    redraw
    call EchoWarning(v:exception)
  endtry
endfunction "}}}
"}}}

"buffer{{{
nnoremap <silent> <Leader>bn :<C-u>bn<CR>
nnoremap <silent> <Leader>bp :<C-u>bp<CR>
nnoremap <silent> <Leader>bb :<C-u>call <SID>BufferSelect(0)<CR>
nnoremap <silent> <Leader>BB :<C-u>call <SID>BufferSelect(1)<CR>
function! s:BufferSelect(bang) "{{{
  if exists(':Unite') is 2
    exe 'Unite -buffer-name=buffer buffer' . (a:bang ? ':!' : '')
  else
    exe 'buffers' . (a:bang ? '!' : '')
    call inputsave()
    let l:buffer = input('buffer: ', '', 'buffer')
    if !empty(l:buffer)
      exe 'buffer '.l:buffer
    endif
    call inputrestore()
  endif
endfunction "}}}
"}}}

"window"{{{
nmap \ <C-w>
nnoremap \\ <C-w><C-w>
nnoremap <C-n> <C-w>w
nnoremap <C-p> <C-w>W
nnoremap <Leader>n <C-w>w
nnoremap <Leader>N <C-w>W
nnoremap [Plug]N <C-w>W
nnoremap <Leader>j <C-W>w
"}}}

"tab"{{{
nnoremap <silent> <C-w><C-t> :<C-u>enew<CR>:tabedit #<CR>

nnoremap <Leader>gn :<C-u>tablast<CR>
nnoremap <Leader>gp :<C-u>tabfirst<CR>
nnoremap <silent> <Leader>l :<C-u>call <SID>SwitchTab('n')<CR>
nnoremap <silent> <Leader>h :<C-u>call <SID>SwitchTab('p')<CR>

nnoremap <silent> <Leader>T :<C-u>call <SID>SwitchTab('m', 1)<CR>
nnoremap <silent> <Leader>m :<C-u>call <SID>SwitchTab('m', 1)<CR>
function! s:SwitchTab(command, ...) "{{{
  if !empty(a:000) && a:1 is 1
    let l:count = (v:count > 0 ? v:count - 1 : v:count)
  else
    let l:count = (v:count is 0 ? '' : v:count)
  endif
  exe 'tab'.a:command.l:count
  return ''
endfunction "}}}

nnoremap <silent> <S-F4> :tab ball<CR>
nnoremap <silent> <Leader>e :Enew<CR>
"}}}

"window tab"{{{
function! s:FocusWinOrTab(previous) "{{{
  if v:count > 0
    execute 'tab'.(a:previous ? 'previous' : 'next').v:count
  else
    execute "normal \<C-w>".(a:previous ? "W" : "w")
  endif
endfunction "}}}
nnoremap <silent> <Leader><Space> :<C-u>call <SID>FocusWinOrTab(0)<CR>
nnoremap <silent> [Plug]<S-Space> :<C-u>call <SID>FocusWinOrTab(1)<CR>
function! s:NextWinTab() "{{{
  if tabpagewinnr(tabpagenr()) == tabpagewinnr(tabpagenr(), '$')
    tabnext
    1wincmd w
  else
    wincmd w
  endif
endfunction "}}}
nnoremap <silent> <C-Tab> :<C-u>call <SID>NextWinTab()<CR>
function! s:PreviousWinTab() "{{{
  if tabpagewinnr(tabpagenr()) is 1
    tabprevious
    $wincmd w
  else
    wincmd W
  endif
endfunction "}}}
nnoremap <silent> <C-S-Tab> :<C-u>call <SID>PreviousWinTab()<CR>
"}}}

"closing"{{{
"h window
nnoremap <Leader>q :bw<CR>
nnoremap <Leader>Q :bw!<CR>
nnoremap <Leader>wq <C-w>q
"}}}

"tags-and-searches"{{{
noremap <silent> gf <C-w>gF
noremap <silent> gF <C-w>gf
nnoremap <silent> <Leader>k :vertical help <C-r><C-w><CR>
vnoremap <silent> <Leader>k "vy:vertical help <C-r>v<CR>
nnoremap <silent> <Leader>K :tab help <C-r><C-w><CR>
nnoremap <silent> g<C-]> :tab tag <C-r><C-w><CR>
nnoremap <silent> <C-]> :tab tjump <C-r><C-w><CR>
noremap <Leader>tp :pop<CR>
noremap <Leader>tn :tag<CR>
"}}}

"search-commands"{{{
":h search-offset
if !g:is_android
  noremap / :<C-u>let g:cword = expand('<cword>')<CR>q/
  noremap q/ /
  noremap <Leader>/ /\v
  noremap ? ?\v
  noremap <Leader>?? q?\v
endif
"}}}

"Substitute"{{{
nnoremap <Leader>rr q:%s/\v/geI#<C-o>F/
vnoremap <Leader>rr q:s/\v/geI#<C-o>F/
"}}}

"global"{{{
nnoremap <Leader>gg q:%g//normal<Space>
vnoremap <Leader>gg q:g//normal<Space>
nnoremap <Leader>GG q:%g!//normal<Space>
vnoremap <Leader>GG q:g!//normal<Space>
"}}}

"Esc{{{
if g:is_windows || has('gui_running')
  nnoremap <silent> <Esc> :<C-u>nohlsearch<CR><Esc>
  inoremap <silent> <Esc> <Esc>:<C-u>setl iminsert=0<CR>
else
  nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR><Esc>
  inoremap <silent> <Esc><Esc> <Esc>:<C-u>setl iminsert=0<CR>
endif

if has('gui_running')
  imap <C-c> <Esc>
endif
"}}}

"Undo"{{{
nnoremap U <C-r>
nnoremap <Leader>U U
"}}}

"diff"{{{
noremap <Leader>dg :diffget<CR>
noremap <Leader>dp :diffput<CR>
nnoremap <Leader>du :<C-u>diffupdate<CR>
nnoremap <Leader>dd :<C-u>diffthis<CR>
nnoremap <Leader>dk [c
nnoremap <Leader>dj ]c
"like DF
nnoremap <F7> [c
nnoremap <F8> ]c
"}}}

"scrolling"{{{
nnoremap <Leader>= <C-w>=

nnoremap <expr> <S-Up> ':<C-u>resize -'.v:count1.'<CR>'
nnoremap <expr> <S-Down> ':<C-u>resize +'.v:count1.'<CR>'
nnoremap <expr> <S-Left> ':<C-u>vertical resize -'.v:count1.'<CR>'
nnoremap <expr> <S-Right> ':<C-u>vertical resize +'.v:count1.'<CR>'

nnoremap <silent> <C-Up> :<C-u>wincmd k<CR>
nnoremap <silent> <C-Down> :<C-u>wincmd j<CR>
nnoremap <silent> <C-Left> :<C-u>wincmd h<CR>
nnoremap <silent> <C-Right> :<C-u>wincmd l<CR>

"検索後、スクリーン位置を中央に
nnoremap n nzz
nnoremap N Nzz
nnoremap * *<C-o>zz
nnoremap g* g*<C-o>zz
nnoremap # #zz
nnoremap g# g#zz
"段落移動後、スクリーン位置を中央に
nnoremap { {zz
nnoremap } }zz
"半画面スクロール後、スクリーン位置を中央に
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

"カラム位置を保持して、スクリーン先頭に
noremap zz z<CR>
noremap z<CR> zz

noremap <C-E> <C-E>j
noremap <C-Y> <C-Y>k
"}}}

"2010/07/03: Hack #159: オプションの値を気にせずsplit, vsplitする"{{{
nnoremap <SID>(split-to-j) :<C-u>execute 'belowright' (v:count == 0 ? '' : v:count) 'split'<CR>
nnoremap <SID>(split-to-k) :<C-u>execute 'aboveleft'  (v:count == 0 ? '' : v:count) 'split'<CR>
nnoremap <SID>(split-to-h) :<C-u>execute 'topleft'    (v:count == 0 ? '' : v:count) 'vsplit'<CR>
nnoremap <SID>(split-to-l) :<C-u>execute 'botright'   (v:count == 0 ? '' : v:count) 'vsplit'<CR>

nmap <Leader>wj <SID>(split-to-j)
nmap <Leader>wk <SID>(split-to-k)
nmap <Leader>wh <SID>(split-to-h)
nmap <Leader>wl <SID>(split-to-l)
"}}}
nnoremap <Leader>ws <C-w>s
nnoremap <Leader>wv <C-w>v

if g:is_windows
  "'~' は<Space>
  nnoremap <M-Space> :simalt ~<CR>
endif
nnoremap <silent> <C-r> :<C-u>e<CR>
nnoremap <silent> <F5> :<C-u>e<CR>
nnoremap <silent> <S-F5> :<C-u>noautocmd e<CR>

if g:is_windows
  let s:ConEmu = expand(printf('$PROGRAMFILES/ConEmu/ConEmu%s.exe', has("win64") ? '64' : ''))
  function! s:start_console(shell) abort
    if executable(s:ConEmu)
      execute printf('!start "%s" /Single /Dir "%s" /cmd {Shells::%s}', s:ConEmu, expand('%:p:h'), a:shell)
    else
      execute '!start ' . a:shell
    endif
  endfunction
  nnoremap <silent> <Leader>c<CR> :<C-u>call <SID>start_console('cmd')<CR>
  nnoremap <silent> <Leader>P<CR> :<C-u>call <SID>start_console('powershell')<CR>
endif

nnoremap <silent> <Leader>sp :<C-u>setlocal spell!<CR>:setlocal spell?<CR>

"}}}
"-----------------------------------------------------------------------------
"Plugin:"{{{
"NeoBundle Install"{{{
let s:just_installed_neobundle = 0
if has('vim_starting') && HasVersion('7.2') && !g:is_view
  let s:neobundle_path = expand('$VIMBUNDLE/neobundle.vim')
  if !isdirectory(s:neobundle_path)
    if executable('git')
      exe '!git clone http://github.com/Shougo/neobundle.vim.git' .' '.s:neobundle_path
      let s:just_installed_neobundle = 1
    endif
  endif
  if filereadable(s:neobundle_path . '/plugin/neobundle.vim')
    set runtimepath+=$VIMBUNDLE/neobundle.vim
  endif
endif

let s:neobundle_is_installed = (&rtp =~? 'neobundle\.vim')
"}}}

if s:neobundle_is_installed "{{{
  "NeoBundle{{{
  let g:neobundle#types#git#default_protocol = 'https'
  let g:neobundle#types#hg#default_protocol = 'https'
  let g:neobundle#cache_file = expand('$VIMFILES/tmp/.neobundle.cache') .
    \ (has('gui_running') ? '.gvim' : '.vim')

  let g:neobundle#log_filename = expand('$VIMFILES/tmp/neobundle.log')
  if g:is_windows

    let s:numberOfProcessors = str2float($NUMBER_OF_PROCESSORS)
    let g:neobundle#install_max_processes = float2nr(ceil(s:numberOfProcessors / 2))

    if executable('rm')
      let g:neobundle#rm_command = 'rm -rf'
    elseif executable('rmdir')
      let s:mes = 'Please uninstall rmdir.exe.'
      if exists('*exepath')
        let s:mes .= printf("[%s]", exepath('rmdir'))
      endif
      call EchoError(s:mes)
    else
      let g:neobundle#rm_command = 'rmdir /S /Q'
    endif
  endif

  call Set_default('g:neobundle#default_options', {})
  "}}}

  call neobundle#begin(expand('$VIMBUNDLE')) "filetype off
endif "}}}

" NeoBundle "{{{
if s:neobundle_is_installed && neobundle#load_cache(g:sfile_path)

  NeoBundleFetch 'Shougo/neobundle.vim'
  NeoBundle 'Shougo/neobundle-vim-scripts'
  NeoBundleLazy 'Shougo/dein.vim'

  "Shougo/vimproc{{{
  NeoBundle 'Shougo/vimproc', {
    \   'disabled' : g:is_android,
    \   'build' : {
    \     'linux' : 'make',
    \     'unix' : 'gmake',
    \   },
    \ }
  let g:vimproc#download_windows_dll = 1
  "}}}

  NeoBundleLazy 'Shougo/tabpagebuffer.vim', {
    \   'on_source' : ['unite.vim', 'vimfiler', 'vimshell', ],
    \ }

  "Shougo/unite.vim{{{
  NeoBundleLazy 'Shougo/unite.vim', {
    \   'vim_version' : '7.2',
    \   'on_cmd' : [
    \     { 'name' : ['Unite', 'UniteWithCursorWord',
    \                 'UniteWithInput', 'UniteWithBufferDir', ],
    \       'complete' : 'customlist,unite#complete_source'},
    \   ],
    \ }
  "}}}

  "unite_sources{{{
  "Shougo/neomru.vim {{{
  NeoBundleLazy 'Shougo/neomru.vim', {
    \   'on_ft' : 'all',
    \   'on_source' : ['unite.vim', ],
    \ }
  "}}}

  NeoBundleLazy 'Shougo/neoyank.vim', {
    \   'on_ft' : 'all',
    \   'on_source' : ['unite.vim', ],
    \ }

  NeoBundleLazy 'Shougo/unite-build'

  NeoBundleLazy 'thinca/vim-unite-history', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'Shougo/neossh.vim', {
    \   'on_source' : ['unite.vim', ],
    \ }

  NeoBundleLazy 'osyo-manga/unite-filetype', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'osyo-manga/unite-fold', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'osyo-manga/unite-quickfix', {
    \   'on_source' : ['unite.vim', ],
    \ }

  NeoBundleLazy 'pasela/unite-webcolorname', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'Shougo/unite-help', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'tsukkee/unite-tag', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'ujihisa/unite-colorscheme', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'zhaocai/unite-scriptnames', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'Shougo/unite-outline', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'basyura/outline-cobol', {
    \   'pre_func': 'unite#sources#outline#',
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'basyura/outline-cs', {
    \   'pre_func': 'unite#sources#outline#',
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'shiena/unite-path', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'mattn/unite-gist', {
    \   'on_source' : ['unite.vim', ],
    \ }

  " NeoBundleLazy 'basyura/unite-rails', {
    " \   'on_source' : ['unite.vim', ],
    " \ }

  NeoBundleLazy 'sgur/unite-everything', {
    \   'on_source' : ['unite.vim', ],
    \ }
  NeoBundleLazy 'ujihisa/unite-locate', {
    \   'on_source' : ['unite.vim', ],
    \ }

  "}}}

  "Shougo/vimshell{{{
  NeoBundleLazy 'Shougo/vimshell', {
    \   'vim_version' : '7.2',
    \   'on_ft' : ['vimshrc'],
    \   'on_cmd' : [
    \     { 'name' : ['VimShell', 'VimShellBufferDir', 'VimShellPop',
    \                 'VimShellCurrentDir', 'VimShellTab', ],
    \       'complete' : 'customlist,vimshell#complete'},
    \     { 'name' : ['VimShellExecute', 'VimShellInteractive', ],
    \       'complete' : 'customlist,vimshell#helpers#vimshell_execute_complete'},
    \   ],
    \ }
  "}}}

  "sudo.vim{{{
  NeoBundleLazy 'sudo.vim', {
    \   'frozen' : 1,
    \   'on_cmd' : ['SudoRead', 'SudoWrite', ],
    \ }
  "}}}

  "yomi322/vim-gitcomplete{{{
  NeoBundleLazy 'yomi322/vim-gitcomplete', {
    \   'on_ft' : ['vimshell'],
    \ }
  "}}}

  "Shougo/neocomplete.vim{{{
  NeoBundleLazy 'Shougo/neocomplete.vim', {
    \   'disabled' : !has('lua'),
    \   'vim_version' : '7.3.885',
    \ }

  "}}}

  "osyo-manga/vim-precious"{{{
  NeoBundleLazy 'osyo-manga/vim-precious', {
    \   'on_cmd' : [
    \     {'name' : ['PreciousSwitch',  'PreciousSwitchAutcmd', ],
    \      'complete' : 'filetype'},
    \   ],
    \   'pre_func' : 'precious#',
    \   'on_ft' : 'all',
    \ }
  "}}}

  "Shougo/context_filetype.vim"{{{
  NeoBundleLazy 'Shougo/context_filetype.vim', {
    \   'pre_func' : 'context_filetype#',
    \   'on_source' : ['neocomplete.vim', 'neocomplcache',
    \                  'vim-precious', 'echodoc', ],
    \ }
  "}}}

  "Shougo/neosnippet{{{
  NeoBundleLazy 'Shougo/neosnippet', {
    \   'on_i' : 1,
    \   'depends' : 'Shougo/neosnippet-snippets',
    \   'on_ft' : ['snippet'],
    \   'on_source' : ['unite.vim', ],
    \   'on_func' : 'neosnippet#expandable_or_jumpable',
    \ }
  "}}}

  "Shougo/neosnippet-snippets"{{{
  NeoBundleLazy 'Shougo/neosnippet-snippets', {
    \   'on_source' : ['neosnippet', ],
    \ }
  "}}}

  "honza/vim-snippets{{{
  NeoBundleLazy 'honza/vim-snippets', {
    \   'on_source' : ['neosnippet', ],
    \ }
  "}}}

  "mattn/sonictemplate-vim"{{{
  NeoBundleLazy 'mattn/sonictemplate-vim', {
    \   'on_cmd' : [
    \     { 'name' : 'Template',
    \       'complete' : 'customlist,sonictemplate#complete',},
    \   ],
    \   'on_map' : '<plug>(sonictemplate',
    \   'on_source' : ['unite.vim', ],
    \ }
  "}}}

  "mattn/emmet-vim{{{
  NeoBundleLazy 'mattn/emmet-vim', {
    \   'on_ft' : ['xhtml', 'html', 'css', 'javascript'],
    \   'on_source' : ['unite.vim', ],
    \   'pre_func' : 'emmet#',
    \ }
  "}}}

  "thinca/vim-ambicmd{{{
  NeoBundleLazy 'thinca/vim-ambicmd', {
    \   'on_i' : 1,
    \   'on_ft' : 'vim',
    \   'pre_func' : 'ambicmd#',
    \ }
  "}}}

  " cd01/poshcomplete-vim"{{{
  NeoBundleLazy 'cd01/poshcomplete-vim', {
    \   'on_ft' : ['ps1'],
    \   'pre_func' : 'poshcomplete#',
    \ }
  "}}}

  NeoBundleLazy 'Shougo/neco-syntax', { 'on_source': ['neocomplete.vim',], }

  NeoBundleLazy 'Shougo/neoinclude.vim', { 'on_source': ['neocomplete.vim',], }

  NeoBundleLazy 'Shougo/neco-vim', { 'on_source': ['neocomplete.vim',], }

  NeoBundleLazy 'hrsh7th/vim-neco-calc', { 'on_source': ['neocomplete.vim',], }

  "Shougo/vimfiler{{{
  NeoBundleLazy 'Shougo/vimfiler', {
    \   'depends' : 'Shougo/unite.vim',
    \   'vim_version' : '7.2',
    \   'on_cmd' : [
    \     { 'name' : ['VimFiler', 'VimFilerBufferDir', 'VimFilerCurrentDir',
    \                 'VimFilerDouble', 'VimFilerExplorer', 'VimFilerSimple',
    \                 'VimFilerSplit', 'VimFilerTab', ],
    \       'complete' : 'customlist,vimfiler#complete'},
    \   ],
    \   'pre_func' : 'vimfiler#',
    \   'on_path' : '.*',
    \ }
  "}}}

  "thinca/vim-prettyprint{{{
  NeoBundleLazy 'thinca/vim-prettyprint', {
    \   'on_cmd' : [{'name' : ['PP', 'PrettyPrint'], 'complete' : 'var'}, ],
    \   'on_func' : ['PP', 'PrettyPrint'],
    \ }
  "}}}

  "taku-o/vim-batch-source{{{
  NeoBundleLazy 'taku-o/vim-batch-source', { 'on_cmd' : 'Batch', }
  "}}}

  "which.vim 1.0{{{
  NeoBundleLazy 'which.vim', {
    \   'frozen' : 1,
    \   'on_func' : 'Which',
    \   'on_cmd'  : 'Which',
    \ }
  "}}}

  NeoBundleLazy 'tyru/capture.vim', {
    \   'on_cmd' : [ { 'name': 'Capture', 'complete': 'command', }, ],
    \ }

  "scrooloose/nerdcommenter{{{
  NeoBundleLazy 'scrooloose/nerdcommenter', {
    \   'on_map' : '<plug>NERDCommenter',
    \ }
  "}}}

  "hekyou/vim-rectinsert{{{
  NeoBundleLazy 'hekyou/vim-rectinsert', {
    \   'on_map' : [['nx', '<Plug>', ]],
    \ }
  "}}}

  NeoBundleLazy 'AndrewRadev/switch.vim', { 'on_cmd' : 'Switch', }

  "tpope/vim-surround{{{
  NeoBundleLazy 'tpope/vim-surround', {
    \   'on_map' : [
    \     ['nx', '<Plug>Dsurround', '<Plug>Csurround',
    \            '<Plug>Ysurround', '<Plug>Yssurround'],
    \     ['vx', '<Plug>VgSurround', '<Plug>VSurround'],
    \   ]
    \ }
  "}}}

  "Align "{{{
  NeoBundleLazy 'Align', {
    \   'frozen' : 1,
    \   'on_cmd' : 'Align'
    \ }
  "}}}

  "t9md/vim-quickhl{{{
  NeoBundleLazy 't9md/vim-quickhl', {
    \   'disabled' : !has('gui_running'),
    \   'gui' : 1,
    \   'on_map' : [
    \     ['nx', '<Plug>(quickhl-manual-this)',
    \            '<Plug>(quickhl-cword-toggle)', ],
    \   ],
    \ }
  "}}}

  "t9md/vim-textmanip{{{
  NeoBundleLazy 't9md/vim-textmanip', {
    \   'on_map' :  [['nx', '<Plug>', ]],
    \ }
  "}}}

  "t9md/vim-choosewin{{{
  NeoBundleLazy 't9md/vim-choosewin', {
    \   'on_map' : '<Plug>',
    \   'on_cmd' : 'ChooseWin',
    \ }
  "}}}

  "nathanaelkane/vim-indent-guides{{{
  NeoBundleLazy 'nathanaelkane/vim-indent-guides', {
    \   'on_map' : [['n', '<Plug>IndentGuidesToggle',
    \                       '<Plug>IndentGuidesEnable',
    \                       '<Plug>IndentGuidesDisable',], ],
    \   'on_cmd' : ['IndentGuidesEnable', 'IndentGuidesToggle'],
    \ }
  "}}}

  "number-marks{{{
  NeoBundleLazy 'number-marks', {
    \   'frozen' : 1,
    \   'on_map' : [['n', '<Plug>Place_sign', '<Plug>Goto_next_sign',
    \                 '<Plug>Goto_prev_sign', '<Plug>Remove_all_signs',
    \                 '<Plug>Move_sign'], ],
    \   'command' : ['SaveP', 'ReloadP',],
    \ }
  "}}}

  "colorsel.vim{{{
  NeoBundleLazy 'colorsel.vim', {
    \   'frozen' : 1,
    \   'gui' : 1,
    \   'on_cmd' : 'ColorSel'
    \ }
  "}}}

  "lilydjwg/colorizer{{{
  NeoBundleLazy 'lilydjwg/colorizer', {
    \   'on_cmd' : ['ColorHighlight', 'ColorToggle']
    \ }
  "}}}

  "osyo-manga/vim-anzu{{{
  NeoBundleLazy 'osyo-manga/vim-anzu', {
    \   'gui' :1,
    \   'on_map' : '<Plug>',
    \   'on_cmd' : 'AnzuClearSearchStatus',
    \ }
  "}}}

  "easymotion/vim-easymotion {{{
  NeoBundleLazy 'easymotion/vim-easymotion', {
    \   'on_map' : ['<Plug>', 's'],
    \ }
  "}}}

  "rhysd/clever-f.vim{{{
  NeoBundleLazy 'rhysd/clever-f.vim', {
    \   'on_map' : ['f','F','t','T']
    \ }
  "}}}

  "matchit.zip{{{
  NeoBundleLazy 'matchit.zip' , {
    \   'frozen' : 1,
    \   'on_ft' : ['vim', 'HTML', 'xhtml', 'xml', 'jsp', ],
    \   'on_map' : ['%', 'g%', ],
    \ }
  "}}}

  "osyo-manga/vim-milfeulle{{{
  NeoBundleLazy 'osyo-manga/vim-milfeulle', {
    \   'on_map' : [['n', '<Plug>']],
    \   'on_cmd' : ['MilfeulleDisp', 'MilfeullePrev', 'MilfeulleNext', 'MilfeulleClear',
    \                 'MilfeulleRefreshMilfeulleRefresh', 'MilfeulleOverlay'],
    \   'on_ft' : 'all',
    \ }
  "}}}

  " vim-textobj-user"{{{
  "kana/vim-textobj-user{{{
  NeoBundleLazy 'kana/vim-textobj-user', {
    \   'pre_func' : 'textobj#user#',
    \ }
  "}}}

  "kana/vim-textobj-fold {{{
  NeoBundleLazy 'kana/vim-textobj-fold', {
    \   'on_map' : [['xo', '<Plug>(textobj-fold-a)', '<Plug>(ftextobj-fold-i)']]
    \ }
  "}}}

  "kana/vim-textobj-indent {{{
  NeoBundleLazy 'kana/vim-textobj-indent', {
    \   'on_map' : [['xo', '<Plug>(textobj-indent-a)', '<Plug>(textobj-indent-i)'],
    \                 '<Plug>(textobj-indent-same-a)', '<Plug>(textobj-indent-same-i)',],
    \ }
  "}}}

  "osyo-manga/vim-textobj-multiblock{{{
  "textobj-multiblock つくった - C++でゲームプログラミング
  "http://d.hatena.ne.jp/osyo-manga/20130329/1364569153
  NeoBundleLazy 'osyo-manga/vim-textobj-multiblock', {
    \   'on_map' : [['xo', '<Plug>(textobj-multiblock-a)', '<Plug>(textobj-multiblock-i)', ],],
    \ }
  "}}}

  "thinca/vim-textobj-between{{{
  NeoBundleLazy 'thinca/vim-textobj-between', {
    \   'on_map' : [['xo', '<Plug>(textobj-between-a)', '<Plug>(textobj-between-i)',],]
    \ }
  "}}}

  "}}}

  " vim-operator-user"{{{
  "kana/vim-operator-user{{{
  NeoBundleLazy 'kana/vim-operator-user', {
    \   'pre_func' : 'operator#user#',
    \   'on_source' : ['operator-camelize.vim', 'vim-operator-replace', ],
    \ }
  "}}}

  "kana/vim-operator-replace{{{
  NeoBundleLazy 'kana/vim-operator-replace', {
    \   'on_map' : '<Plug>',
    \ }
  "}}}

  "tyru/operator-camelize.vim{{{
  NeoBundleLazy 'tyru/operator-camelize.vim', {
    \   'on_map' : '<Plug>',
    \ }
  "}}}

  "tyru/operator-html-escape.vim{{{
  NeoBundleLazy 'tyru/operator-html-escape.vim', {
    \   'on_map' : '<Plug>(operator-html-',
    \ }
  "}}}

  "}}}

  "fuenor/im_control.vim{{{
  NeoBundleLazy 'fuenor/im_control.vim', {
    \   'on_func' : ['IMState', 'IMCtrl', ],
    \ }
  "}}}

  "tpope/vim-capslock {{{
  let g:capslock_filetype = ['sql', 'cobol', 'dosbatch']
  NeoBundleLazy 'tpope/vim-capslock', {
    \   'on_map' : [['n', '<Plug>CapsLockToggle', ], ],
    \   'on_ft' : g:capslock_filetype,
    \   'on_cmd' : ['CapsLockToggle', 'CapsLockEnable', 'CapsLockDisable'],
    \ }
  "}}}

  NeoBundleLazy 'vim-jp/vital.vim', { 'pre_func' : 'vital#', }

  "gregsexton/VimCalc{{{
  NeoBundleLazy 'gregsexton/VimCalc', {
    \   'disabled' : !has('python'),
    \   'on_cmd' : 'Calc',
    \ }
  "}}}

  "thinca/vim-scouter{{{
  NeoBundleLazy 'thinca/vim-scouter', {
    \   'on_cmd' : [{ 'name' : 'Scouter', 'complete' : 'file'},],
    \ }
  "}}}

  "mattn/calendar-vim{{{
  NeoBundleLazy 'mattn/calendar-vim', {
    \   'on_map' : [['n', '<Plug>CalendarV', '<Plug>CalendarH']],
    \   'on_cmd' : ['Calendar', 'CalendarH'],
    \ }
  "}}}

  "thinca/vim-ref{{{
  NeoBundleLazy 'thinca/vim-ref', {
    \   'on_cmd' : [{ 'name' : 'Ref', 'complete' : 'customlist,ref#complete'},],
    \   'pre_func' : 'ref#',
    \   'on_source' : ['unite.vim', ],
    \ }
  "}}}

  "thinca/vim-quickrun{{{
  NeoBundleLazy 'thinca/vim-quickrun', {
    \   'on_cmd' : [{ 'name' : 'QuickRun', 'complete' : 'customlist,quickrun#complete'},],
    \   'pre_func' : 'quickrun#',
    \ }
  "}}}

  "tyru/open-browser.vim{{{
  NeoBundleLazy 'tyru/open-browser.vim', {
    \     'on_map' : [['nx', '<Plug>(openbrowser']],
    \     'on_cmd' : ['OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch'],
    \     'pre_func' : 'openbrowser#',
    \     'on_source': ['previm',],
    \ }
  "}}}

  "Shougo/echodoc{{{
  NeoBundleLazy 'Shougo/echodoc', {
    \   'on_cmd' : ['EchoDocEnable'],
    \   'pre_func' : 'echodoc#',
    \   'on_ft' : 'all',
    \ }
  "}}}

  "mattn/gist-vim{{{
  NeoBundleLazy 'mattn/gist-vim', {
    \   'on_cmd' : ['Gist', ],
    \   'on_source' : ['unite-gist', ],
    \ }
  "}}}

  "mattn/webapi-vim{{{
  NeoBundleLazy 'mattn/webapi-vim', {
    \   'on_func' : 'webapi#',
    \   'on_source' : ['gist-vim', 'poshcomplete-vim',],
    \ }
  "}}}

  "thinca/vim-openbuf{{{
  NeoBundleLazy 'thinca/vim-openbuf', {
    \   'pre_func' : 'openbuf#',
    \ }
  "}}}

  "mattn/wwwrenderer-vim{{{
  NeoBundleLazy 'mattn/wwwrenderer-vim', {
    \   'pre_func' : 'wwwrenderer#',
    \ }
  "}}}

  "vim-ruby/vim-ruby{{{
  NeoBundleLazy 'vim-ruby/vim-ruby', {
    \   'on_ft' : ['ruby', 'eruby'],
    \ }
  "}}}

  NeoBundleLazy 'othree/html5.vim', {'on_ft': ['html', 'xhtml'], }

  " NeoBundleLazy 'tpope/vim-rails', {'on_ft': ['ruby', 'eruby'], }

  NeoBundleLazy 'cobol.zip', {
    \   'frozen' : 1,
    \   'on_ft' : ['cobol'],
    \ }

  "hail2u/vim-css3-syntax{
    " \    'on_ft' : ['css', 'html', 'xhtml',],
    " \ }

  "skammer/vim-css-color
  "NeoBundleLazy 'skammer/vim-css-color', {
  "    \ 'script_type' : 'after/syntax',
  "    \ 'autoload' : {
  "    \    'on_ft' : ['css', 'html', 'xhtml', 'javascript'],
  "    \   },
  "    \ }
  "let g:cssColorVimDoNotMessMyUpdatetime = 1

  ""css_color.vim
  "NeoBundleLazy 'css_color.vim', {
  "    \ 'script_type' : 'after',
  "    \ 'autoload' : {
  "    \    'on_ft' : ['css', 'html', 'xhtml', 'javascript'],
  "    \   },
  "    \ }

  "jelera/vim-javascript-syntax
  NeoBundleLazy 'jelera/vim-javascript-syntax', {
    \   'on_ft' : ['javascript'],
    \ }

  NeoBundleLazy 'jQuery', { 'frozen' : 1, 'on_ft': ['javascript'], }

  NeoBundleLazy 'JavaScript-Indent', { 'frozen' : 1, 'on_ft': ['html'], }
  "javacomplete{{{
  "NeoBundleLazy 'javacomplete', {
  "    \ 'autoload' : {
  "    \   'on_ft' : 'java'
  "    \ }}
  "autocmd MyAutoCmd Filetype java setlocal omnifunc=javacomplete#Complete
  "}}}

  "javaid.vim{{{
  NeoBundleLazy 'http://www.fleiner.com/vim/syntax_60/javaid.vim', {
    \   'name' : 'javaid.vim',
    \   'frozen' : 1,
    \   'directory' : 'java.vim',
    \   'type' : 'raw',
    \   'type__filename' : 'javaid.vim',
    \   'script_type' : 'syntax',
    \   'stay_same' : 1,
    \   'build' : {
    \     'windows' : printf('cp -p "%S" "%S"',
    \                 expand('$VIMRUNTIME/syntax/java.vim'),
    \                 expand('$VIMBUNDLE/java.vim/syntax/java.vim'))
    \                 . '|' .
    \                 printf('cp -p "%S" "%S"',
    \                 expand('$VIMRUNTIME/syntax/html.vim'),
    \                 expand('$VIMBUNDLE/java.vim/syntax/html.vim')) ,
    \   },
    \   'on_ft' : ['java'],
    \ }
  call neobundle#config('javaid.vim', {
    \   'type__filepath' : (neobundle#get('javaid.vim').path) . '/javaid.vim',
    \ })
  "}}}

  NeoBundleLazy 'java_fold', { 'frozen' : 1, 'on_ft' : ['java'], }

  NeoBundle 'vim-scripts/Windows-PowerShell-indent-enhanced'
  NeoBundleLazy 'PProvost/vim-ps1', { 'on_ft' : ['ps1'], }

  NeoBundleLazy 'pearofducks/ansible-vim', { 'on_ft' : ['ansible', 'ansible_template', 'ansible_hosts'], }

  NeoBundleLazy 'plasticboy/vim-markdown', { 'on_ft' : ['markdown'], }
  NeoBundleLazy 'kannokanno/previm', {
    \   'on_ft': ['markdown'],
    \   'on_cmd': ['PrevimOpen', ],
    \   'augroup': 'previm',
    \ }

  NeoBundleLazy 'stephpy/vim-yaml', { 'on_ft' : ['yaml'], }

  NeoBundleLazy 'evanmiller/nginx-vim-syntax', { 'on_ft' : ['nginx'], }

  NeoBundleLazy 'ekalinin/Dockerfile.vim', { 'on_ft' : ['Dockerfile', 'docker-compose'], }

  NeoBundleLazy 'vim-jp/vimdoc-ja'
  NeoBundleLazy 'chrisbra/vim_faq'

  "thinca/vim-qfreplace"{{{
  NeoBundleLazy 'thinca/vim-qfreplace', {
    \   'on_ft' : ['unite', 'quickfix'],
    \   'on_cmd' : ['Qfreplace',],
    \ }
  "}}}

  "haya14busa/vim-migemo{{{
  NeoBundle 'haya14busa/vim-migemo', {
    \   'on_map' : [['n', '<Plug>(migemo-searchchar)']],
    \   'on_i' : 1,
    \   'disabled' : has('migemo')
    \ }
  "}}}

  NeoBundleLazy 'mopp/layoutplugin.vim', { 'on_cmd' : 'LayoutPlugin', }

  NeoBundleLazy 'iwataka/gitignore.vim', {
    \   'on_func' : 'gitignore#',
    \   'on_cmd' : [
    \     { 'name' : 'Gitignore', 'complete' : 'customlist,gitignore#complete'},
    \     'GitignoreUpdate',
    \   ],
    \ }

  NeoBundleFetch 'sonota/anbt-sql-formatter',{
    \   'base' : expand('$HOME/bin'),
    \ }
  NeoBundleFetch 'gist:nakahiro386/1f32bbaf59ae4b2987dc',{
    \   'name' : 'my-sql-formatter.rb',
    \   'regular_name' : 'my-sql-formatter',
    \   'base' : expand('$HOME/bin'),
    \   'site' : 'gist',
    \ }

  NeoBundleSaveCache
endif "if s:neobundle_is_installed && neobundle#load_cache()"}}}

" NeoBundleLocal "{{{
if s:neobundle_is_installed
  "NeoBundleLocal $VIMBUNDLELOCAL
  call extend(g:neobundle#default_options ,
    \   { 'local' : {
    \       'type' : 'none',
    \       'base' : $VIMBUNDLELOCAL,
    \       'stay_same' : 1,
    \       'local' : 1,
    \     },
    \   }
    \ )
  let g:bundle_name = ''
  function! IsLocal() abort
    return isdirectory(expand('$VIMBUNDLELOCAL/'.g:bundle_name))
  endfunction

  "sqlformatter.vim{{{
  let g:bundle_name = 'sqlformatter.vim'
  NeoBundleLazy 'bitbucket:nakahiro386/sqlformatter.vim.git', {
    \   'default' : (IsLocal() ? 'local' : '_' ),
    \   'type': (IsLocal() ? 'none' : 'git'),
    \   'on_cmd' : 'Sqlformatter',
    \   'on_map' : '<Plug>(Sqlformatter)',
    \ }
  "}}}

  "sonictemplate-vim-templates{{{
  let g:bundle_name = 'sonictemplate-vim-templates'
  NeoBundleLazy 'bitbucket:nakahiro386/sonictemplate-vim-templates', {
    \   'default' : (IsLocal() ? 'local' : '_' ),
    \   'type': (IsLocal() ? 'none' : 'git'),
    \   'on_source' : ['sonictemplate-vim', ],
    \ }
  "}}}

  "thinca/vim-fontzoom vim-fontzoom The fontsize controller in gVim.{{{
  let g:bundle_name = 'vim-fontzoom'
  NeoBundleLazy 'thinca/vim-fontzoom', {
    \   'default' : (IsLocal() ? 'local' : '_' ),
    \   'type': (IsLocal() ? 'none' : 'git'),
    \   'gui' : 1,
    \   'on_cmd': ['Fontzoom',],
    \   'on_map': [['n', '<Plug>', ]],
    \ }
  "}}}

  "emmet_complete.vim{{{
  "neocomplcache で zencoding.vim 内の snippets を補完する - cooldaemonの備忘録
  "http://d.hatena.ne.jp/cooldaemon/20100709/1278675260
  "neocomplcache + zencoding
  "https://gist.github.com/cooldaemon/469369
  let g:bundle_name = 'emmet_complete.vim'
  NeoBundleLazy 'emmet_complete.vim', {
    \   'default' : 'local',
    \   'disabled' : !IsLocal(),
    \   'on_ft' : ['html', 'css', 'javascript'],
    \ }
  "}}}

  let g:bundle_name = 'vagrant-complete.vim'
  NeoBundleLazy 'bitbucket:nakahiro386/vagrant-complete.vim', {
    \   'default' : (IsLocal() ? 'local' : '_' ),
    \   'type': (IsLocal() ? 'none' : 'git'),
    \   'on_ft' : ['vimshell'],
    \ }

  if !s:has_kaoriya || (s:has_kaoriya && (get(g:, 'vimrc_local_finish', 0) != 0))
    "hz_ja.vim{{{
    let g:bundle_name = 'hz_ja.vim'
    NeoBundleLazy 'hz_ja.vim', {
      \   'default' : 'local',
      \   'disabled' : !IsLocal(),
      \   'on_cmd' : ['Hankaku', 'Zenkaku', 'ToggleHZ'],
      \ }
    "}}}
    "verifyenc.vim{{{
    let g:bundle_name = 'verifyenc.vim'
    NeoBundleLazy 'verifyenc.vim', {
      \   'default' : 'local',
      \   'disabled' : !IsLocal(),
      \   'on_cmd' : ['VerifyEnc',],
      \   'on_ft' : 'all',
      \   'on_i' : 1,
      \ }
    "}}}
    "memo.vim{{{
    let g:bundle_name = 'memo.vim'
    NeoBundleLazy 'memo.vim', {
      \   'default' : 'local',
      \   'disabled' : !IsLocal(),
      \   'on_ft' : ['memo'],
      \ }
    "}}}
  endif
  unlet g:bundle_name
endif "}}}

"Tap"{{{
if s:neobundle_is_installed "{{{
  function! Tap(name) "{{{
    if !neobundle#is_installed(a:name)
      return 0
    endif
    let l:exists = neobundle#tap(a:name)
    return l:exists && !get(g:neobundle#tapped, 'disabled', 1)
  endfunction "}}}
  function! UnTap() "{{{
    return neobundle#untap()
  endfunction "}}}
  function! NeoBundleEnd() "{{{
    call UnTap()
    return neobundle#end()
  endfunction "}}}
else
  function! Tap(name) "{{{
    return 0
  endfunction "}}}
  function! UnTap() "{{{
    return 0
  endfunction "}}}
  function! NeoBundleEnd() "{{{
    call UnTap()
    return 0
  endfunction "}}}
endif "if s:neobundle_is_installed"}}}

if Tap('vimproc') "{{{
  function! Download_vimproc_dll(version) abort "{{{
    if !g:is_windows || !executable('powershell')
      return
    endif

    let l:url_base = 'https://github.com/Shougo/vimproc.vim/releases/download/ver.%s/%s'
    let l:url = printf(l:url_base, a:version, fnamemodify(g:vimproc#dll_path, ':t'))

    let l:tmpfile = tempname().'.ps1'
    let l:write = []
    call add(l:write, '$wc = new-object System.Net.WebClient')
    call add(l:write, '$proxy = [System.Net.WebRequest]::GetSystemWebProxy()')
    call add(l:write, '$proxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials')
    call add(l:write, '$wc.Proxy = $proxy')
    call add(l:write, 'try {')
    call add(l:write, printf('$wc.DownloadFile("%s", "%s")', l:url, g:vimproc#dll_path))
    call add(l:write, '} catch [System.Net.WebException] {')
    call add(l:write, 'if ($_.Exception -match ".*\(407\).*") {')
    call add(l:write, '$cred = get-credential')
    call add(l:write, '$wc.Proxy.Credentials = $cred.GetNetworkCredential()')
    call add(l:write, printf('$wc.DownloadFile("%s", "%s")', l:url, g:vimproc#dll_path))
    call add(l:write, '} else {')
    call add(l:write, 'throw')
    call add(l:write, '}')
    call add(l:write, '}')
    call writefile(l:write, l:tmpfile)
    let l:ret =  system(printf('powershell -File "%s"', l:tmpfile))

    call delete(l:tmpfile)
    return l:ret
  endfunction "}}}
  " echo Download_vimproc_dll('9.2')
  " echo vimproc#util#try_download_windows_dll('9.2')
endif "}}}

if Tap('unite.vim') "{{{
  "unite-mapping{{{
  "unite prefix key.
  nnoremap [unite] <Nop>
  nmap <C-Space> [unite]
  nmap [Plug]u [unite]
  nmap <Leader>u [unite]

  "command! -nargs=* -complete=mapping Mapping Unite -buffer-name=mapping mapping -input=<args>
  command! -nargs=* -complete=mapping Mapping Unite -buffer-name=mapping output:AllMaps -input=<args>

  "現在開いているファイルのディレクトリ下のファイル一覧。
  nnoremap <silent> [unite]F :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
  nnoremap <silent> [unite]w :<C-u>Unite -buffer-name=window -auto-resize -quick-match window<CR>
  nnoremap <silent> <Leader>b<CR> :<C-u>Unite -buffer-name=buffer_tab buffer_tab<CR>
  nnoremap <silent> [unite]b :<C-u>Unite -buffer-name=buffer_tab buffer_tab<CR>
  nnoremap <silent> [unite]B :<C-u>Unite -buffer-name=buffer_tab buffer_tab:!<CR>
  nnoremap <silent> [unite]R :<C-u>Unite resume<CR>
  nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register -default-action=yank -truncate register history/yank history/search history/command<CR>
  nnoremap <silent> [unite]m :<C-u>Unite -default-action=tabopen -buffer-name=files file_mru bookmark<CR>
  " nnoremap <silent> [unite]D :<C-u>Unite -default-action=tabvimfilerFF -buffer-name=directory_mru directory_mru bookmark:directory<CR>
  nnoremap <silent> [unite]D :<C-u>Unite -buffer-name=directory_mru directory_mru bookmark:directory<CR>
  nnoremap <silent> [unite]h :<C-u>Unite -buffer-name=help help<CR>
  nnoremap <silent> [unite]H :<C-u>UniteWithCursorWord -immediately -buffer-name=help help<CR>
  nnoremap <silent><expr> [unite]s  ":\<C-u>:UniteWithInput -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line:all\<CR>"
  nnoremap <silent><expr> [unite]S  ":\<C-u>:UniteWithCursorWord -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line:all\<CR>"
  nnoremap <silent><expr> [unite]/  ":\<C-u>Unite -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line:all\<CR>"
  nnoremap <silent><expr> [unite]g/ ":\<C-u>Unite -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line_migemo:all\<CR>"
  nnoremap <silent> [unite]c :<C-u>Unite -buffer-name=bookmark -default-action=tabopen bookmark:default<CR>
  " nnoremap <silent> [unite]d :<C-u>Unite -default-action=tabVimFilerFF bookmark:directory<CR>
  nnoremap <silent> [unite]d :<C-u>Unite bookmark:directory<CR>
  nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>

  if g:is_windows
    nnoremap [unite]e :<C-u>Unite -buffer-name=everything -default-action=tabopen everything/async -input=
  else
    nnoremap [unite]e :<C-u>Unite -buffer-name=locate -default-action=tabopen locate -input=
  endif
  nnoremap [unite]l :<C-u>Unite -toggle -buffer-name=menu -winheight=3 menu:shortcut bookmark<CR>
  nnoremap [unite]L :<C-u>Unite -toggle -buffer-name=launcher launcher<CR>
  nnoremap [unite]M :<C-u>Mapping<CR>
  nnoremap [unite]o :<C-u>Unite -buffer-name=outline outline<CR>
  nnoremap [unite]O :<C-u>Unite -buffer-name=outline outline:!<CR>
  nnoremap [unite]f :<C-u>Unite -vertical -no-quit -winwidth=50 -buffer-name=fold fold<CR>
  nnoremap [unite]<C-]> :<C-u>UniteWithCursorWord -buffer-name=tag -immediately -toggle tag<CR>
  nnoremap [unite]; :<C-u>Unite -buffer-name=command command menu:shortcut -default-action=execute<CR>
  nnoremap [unite]u :<C-u>Unite -buffer-name=source -resume source<CR>
  nnoremap [unite]? :<C-u>Mapping [unite]<CR>
  nnoremap [unite]git :<C-u>Unite -buffer-name=file_rec file_rec/git<CR>
  "}}}

  autocmd MyAutoCmd QuickFixCmdPost [^l]* Unite -buffer-name=quickfix quickfix
  autocmd MyAutoCmd QuickFixCmdPost [^l]* doautocmd FileType
  autocmd MyAutoCmd QuickFixCmdPost l* exe 'Unite -profile-name=location_list -buffer-name=location_list' . bufnr('%'). ' location_list'
  autocmd MyAutoCmd QuickFixCmdPost l* doautocmd FileType

  function! neobundle#hooks.on_source(bundle) "{{{
    let g:unite_data_directory = expand('$VIMFILES/tmp/.unite')
    let g:unite_source_bookmark_directory = expand('$VIMFILES/unite_bookmark')

    let g:unite_enable_auto_select = 1

    let g:unite_split_rule = "botright"
    let g:unite_source_buffer_time_format = ''
    let g:unite_source_history_yank_enable = 1
    let g:unite_source_history_yank_limit = 5
    let g:unite_source_history_yank_save_clipboard = 0
    let g:unite_force_overwrite_statusline = 0

    call Set_default('g:unite_source_alias_aliases', {})
    let g:unite_source_alias_aliases.calc = 'kawaii-calc'
    let g:unite_source_alias_aliases.line_migemo = 'line'

    if executable('jvgrep') "{{{
      let g:unite_source_grep_command = 'jvgrep'
      let g:unite_source_grep_default_opts = '--exclude ''\.(git|svn|hg|bzr|exe|jar|zip|xlsx|xls)$'' -in8'
      let g:unite_source_grep_recursive_opt = '-R'
      let g:unite_source_grep_max_candidates = 1000
      let g:unite_source_grep_encoding = 'utf-8'
    endif "}}}

    "unite StatusLine Settings"{{{
    function! UniteStatusLine() "{{{
      let l:ret=' '
      let l:ret.='%#StatusLineModeMsgVl#[*%{Bufpath()}*]%*'
      let l:ret.='[%{unite#get_status_string()}]'
      let l:ret.='%#Error#%h%w%q%r%m%*'
      let l:ret.=StatuslineGetMode()
      let l:ret.='%<'
      let l:ret.='%='
      let l:ret.=StatusLineBufNum()
      let l:ret.=StatuslineSuffix()
      return l:ret
    endfunction "}}}
    "}}}
    function! s:uniteSetting() "{{{
      setlocal statusline=%!UniteStatusLine()
      call UnmapBuffer('<Space>', 'n')
      call UnmapBuffer('<S-Space>', 'n')
      nmap <buffer> ? <Plug>(unite_quick_help)|
      nmap <buffer> ss <Plug>(unite_toggle_mark_current_candidate)
      nmap <buffer> SS <Plug>(unite_toggle_mark_current_candidate_up)
      nmap <buffer> <ESC><ESC> <Plug>(unite_exit)
      nmap <buffer> qq <Plug>(unite_exit)
      imap <buffer> jj <Plug>(unite_insert_leave)
      "入力モードのときバックスラッシュも削除
      imap <buffer> <C-w> <Plug>(unite_delete_backward_path)

      nmap <buffer> r <Plug>(unite_rotate_next_source)
      nmap <buffer> R <Plug>(unite_rotate_previous_source)
      nnoremap <buffer> <C-n> <C-w>w
      nnoremap <buffer> <C-p> <C-w>W

      imap <buffer> <C-@> <Plug>(unite_quick_match_default_action)
      nmap <buffer> @ <Plug>(unite_quick_match_default_action)

      nmap <buffer> I ggk<Plug>(unite_insert_enter)
      nmap <buffer> A ggk<Plug>(unite_append_end)

    endfunction "}}}

  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    call unite#custom_default_action('file,file_mru,bookmark', 'tabopen')
    "call unite#custom_default_action('directory', 'file')
    call unite#custom_default_action('directory' , 'vimfiler')
    call unite#custom_default_action('directory,directory_mru' , 'vimfiler')
    call unite#custom_default_action('tag', 'vsplit')
    call unite#custom_default_action('command', 'execute')
    if has('migemo')
      call unite#custom_source('file_mru,bookmark,buffer,menu,line_migemo,fold', 'matchers', 'matcher_migemo')
    endif
    call unite#custom_source('line', 'max_candidates', 1000)
    call unite#custom_source('line_migemo', 'max_candidates', 50)

    call unite#custom#source('file_rec/git', 'matchers',
      \ ['converter_relative_word', 'matcher_default',])

    "unite#custom#profile"{{{

    call unite#custom#profile('default', 'context', {
      \   'start_insert' : 1,
      \   'short_source_names' : 0,
      \   'split_rule' : 'botright',
      \   'winheight' : 10,
      \   'winwidth' : 50,
      \   'toggle' : 1,
      \   'auto_resize' : 0,
      \   'prompt_direction' : 'top',
      \   'prompt_visible' : 1,
      \   'prompt' : '> ',
      \   'candidate_icon' : '-',
      \   'hide_icon' : 0,
      \ })

    let l:dc = unite#get_profile('default', 'context')
    call unite#custom#profile('files', 'context', l:dc)
    call unite#custom#profile('completion', 'context', extend(deepcopy(l:dc), {
      \   'auto_resize' : 1,
      \   'winheight' : 10,
      \ }, 'force'))

    let l:nbc = {
      \   'log' : 1,
      \   'start_insert' : 0,
      \   'cursor_line' : 0,
      \ }
    let l:nbc = extend(deepcopy(l:dc), l:nbc, 'force')
    call unite#custom#profile('neobundle', 'context', l:nbc)
    call unite#custom#profile('neobundleinstall', 'context', l:nbc)
    call unite#custom#profile('neobundleupdate', 'context', l:nbc)
    call unite#custom#profile('neobundlelog', 'context',
      \   extend(deepcopy(l:nbc), { 'log' : 0, }))

    call unite#custom#profile('buffer_tab', 'context', extend(deepcopy(l:dc), {
      \   'cursor_line' : 0,
      \   'auto_resize' : 1,
      \ }, 'force'))
    call unite#custom#profile('buffer', 'context', extend(deepcopy(l:dc), {
      \   'cursor_line' : 0,
      \   'winheight' : 10,
      \ }, 'force'))
    call unite#custom#profile('outline', 'context', extend(deepcopy(l:dc), {
      \   'start_insert' : 0,
      \   'cursor_line' : 0,
      \   'no_quit' : 1,
      \   'winwidth' : 20,
      \   'vertical' : 1,
      \ }, 'force'))

    let l:qc = extend(deepcopy(l:dc), {
      \   'no_quit' : 1,
      \   'start_insert' : 0,
      \   'truncate' : 0,
      \   'wrap' : 0,
      \   'multi_line' : 0,
      \   'max_multi_lines' : 0
      \ }, 'force')
    call unite#custom#profile('source/grep', 'context', l:qc)
    call unite#custom#profile('source/quickfix', 'context', l:qc)
    call unite#custom#profile('quickfix', 'context', l:qc)
    call unite#custom#profile('location_list', 'context', l:qc)
    "}}}

    "unite-source"{{{
    "emmet{{{
    let s:unite_source = { 'name': 'emmet', 'max_candidates': 100 }
    function! s:unite_source.gather_candidates(args, context) "{{{
      let snips = emmet#getSnippets(neocomplete#get_context_filetype())
      if empty(snips)
        return []
      endif

      let l:abbr_pattern = printf('%%.%ds..%%s', g:neocomplete#max_keyword_width-10)

      let list = []
      for trig in keys(snips)
        let s:triger = snips[trig]
        let l:abbr = substitute( substitute(s:triger, '\n', '', 'g'), '\s', ' ', 'g')
        let list += [{'word' : trig, 'abbr' : trig . '   ' . l:abbr, 'source' : 'emmet', 'kind' : 'word'}]
      endfor
      unlet trig

      return list
    endfunction "}}}
    "登録
    call unite#define_source(s:unite_source)
    unlet s:unite_source
    "}}}

    "}}}

    "unite-custom_action"{{{
    if g:is_windows "{{{
      " explorer.exe"{{{
      if executable('explorer.exe')
        let explorer_action = { 'description' : 'explorer.exe', 'is_selectable' : 1 }
        function! explorer_action.func(candidates)
          let l:candidates_pass = join(map(deepcopy(a:candidates), '"\"" . fnamemodify(expand(v:val.action__path), ":p:gs?/?\\?:s?[\\\\/]$??") . "\""'), ' ')
          call Start($WINDIR.'\explorer.exe' . ' /n, ' . l:candidates_pass)
        endfunction
        call unite#custom_action('file', 'explorer.exe', explorer_action)
        unlet explorer_action
      endif
      "}}}

      "bluewind＆単機能ツール集 再配布所
      "http://www.web-ghost.net/bluewind/
      "contextmenu"{{{
      if executable('ContextMenu.exe')
        let contextmenu_action = { 'description' : 'contextmenu', 'is_selectable' : 1 }
        function! contextmenu_action.func(candidates)
          let l:candidates_pass = join(map(deepcopy(a:candidates), '"\"" . fnamemodify(expand(v:val.action__path), ":p:gs?/?\\?:s?[\\\\/]$??") . "\""'), ' ')
          call Start('ContextMenu.exe' . ' /X=440 /Y=462 ' . l:candidates_pass)
        endfunction
        call unite#custom_action('file', 'contextmenu', contextmenu_action)
        unlet contextmenu_action
      endif
      "}}}
      "FileProperty"{{{
      if executable('FileProperty.exe')
        let fileproperty_action = { 'description' : 'fileproperty', 'is_selectable' : 1 }
        function! fileproperty_action.func(candidates)
          let l:candidates_pass = join(map(deepcopy(a:candidates), '"\"" . fnamemodify(expand(v:val.action__path), ":p:gs?/?\\?:s?[\\\\/]$??") . "\""'), ' ')
          call Start('FileProperty.exe' . ' ' . l:candidates_pass)
        endfunction
        call unite#custom_action('file', 'fileproperty', fileproperty_action)
        unlet fileproperty_action
      endif
      "}}}

      "office_readonly"{{{
      if executable(g:office_readonly_path)
        let office_readonly_action = { 'description' : 'office_readonly', 'is_selectable' : 1 }
        function! office_readonly_action.func(candidates)
          let l:candidates_pass = join(map(deepcopy(a:candidates), '"\"" . fnamemodify(expand(v:val.action__path), ":p:gs?/?\\?:s?[\\\\/]$??") . "\""'), ' ')
          echo CmdStart(g:office_readonly_path . ' ' . l:candidates_pass )
        endfunction
        call unite#custom_action('file', 'office_readonly', office_readonly_action)
        unlet office_readonly_action
      endif
      "}}}
      "CraftDrop"{{{
      if executable(g:cdrop)
        let cdrop_action = { 'description' : 'cdrop', 'is_selectable' : 1 }
        function! cdrop_action.func(candidates)
          let l:candidates_pass = join(map(deepcopy(a:candidates), '"\"" . fnamemodify(expand(v:val.action__path), ":p:gs?/?\\?:s?[\\\\/]$??") . "\""'), ' ')
          call Start(g:cdrop . ' ' . l:candidates_pass)
        endfunction
        call unite#custom_action('file', 'cdrop', cdrop_action)
        unlet cdrop_action
      endif
      "}}}
    endif "}}}

    "VimFilerFF"{{{
    let vfff_action = { 'description' : 'tabVimFilerFF', 'is_selectable' : 0 }
    function! vfff_action.func(candidates)
      let l:path = has_key(a:candidates, 'action__directory') ? a:candidates.action__directory : a:candidates.action__path
      execute 'VimFiler -buffer-name=ff -tab ' . l:path
    endfunction
    call unite#custom_action('directory', 'tabVimFilerFF', vfff_action)
    unlet vfff_action
    "}}}
    "VimFilerExplorer"{{{
    let vfe_action = { 'description' : 'tabVimFilerExplorer', 'is_selectable' : 0 }
    function! vfe_action.func(candidates)
      let l:path = has_key(a:candidates, 'action__directory') ? a:candidates.action__directory : a:candidates.action__path
      execute 'VimFilerExplorer -buffer-name=fe -tab ' . l:path
    endfunction
    call unite#custom_action('directory', 'tabVimFilerExplorer', vfe_action)
    unlet vfe_action

    let vfe_action = { 'description' : 'VimFilerExplorer', 'is_selectable' : 0 }
    function! vfe_action.func(candidates)
      let l:path = has_key(a:candidates, 'action__directory') ? a:candidates.action__directory : a:candidates.action__path
      execute 'VimFilerExplorer -buffer-name=fe ' . l:path
    endfunction
    call unite#custom_action('directory', 'VimFilerExplorer', vfe_action)
    unlet vfe_action
    "}}}

    "}}}

    "unite-menu"{{{
    call Set_default('g:unite_source_menu_menus', {})

    "Reload with encoding"{{{
    let s:c = { 'description' : 'Reload with encoding' }
    let s:c.command_candidates = []
    for enc in s:fencs
      call add(s:c.command_candidates, [enc, 'edit ++enc='.enc])
    endfor
    unlet enc

    let g:unite_source_menu_menus["reload_encoding"] = deepcopy(s:c)
    unlet s:c
    "}}}
    "Set fileencoding"{{{
    let s:c = { 'description' : 'Set fileencoding' }
    let s:c.command_candidates = []
    for enc in s:fencs
      call add(s:c.command_candidates, [enc, 'setlocal fileencoding='.enc])
    endfor
    unlet enc

    let g:unite_source_menu_menus["set_fileencoding"] = deepcopy(s:c)
    unlet s:c
    "}}}
    "Reload with fileformat"{{{
    let s:c = { 'description' : 'Reload with fileformat' }
    let s:c.command_candidates = []

    for ff in split(&fileformats, ',')
      call add(s:c.command_candidates, [ff, 'edit ++fileformat='.ff])
    endfor
    unlet ff

    let g:unite_source_menu_menus["reload_fileformat"] = deepcopy(s:c)
    unlet s:c
    "}}}
    "Set fileformat"{{{
    let s:c = { 'description' : 'Set fileformat' }
    let s:c.command_candidates = []

    for ff in split(&fileformats, ',')
      call add(s:c.command_candidates, [ff, 'setlocal fileformat='.ff])
    endfor
    unlet ff

    let g:unite_source_menu_menus["set_fileformat"] = deepcopy(s:c)
    unlet s:c
    "}}}

    "Shortcut{{{
    let s:c = { 'description' : 'Shortcut' }
    let s:c.command_candidates = []

    function! s:readLauncher(candidates, file) "{{{
      let l:file = expand(a:file)
      if filereadable(l:file)
        for l:line in readfile(l:file)
          if l:line !~? '^"'
            call add(a:candidates, split(l:line, "\t"))
          endif
        endfor
      endif
    endfunction "}}}

    call s:readLauncher(s:c.command_candidates, '$VIMFILES/launcher.vim')
    if g:is_windows
      call s:readLauncher(s:c.command_candidates, '$VIMFILES/launcher_win.vim')
    endif
    call s:readLauncher(s:c.command_candidates, '$VIMFILES/launcher_local.vim')

    let g:unite_source_menu_menus["shortcut"] = deepcopy(s:c)
    unlet s:c
    "}}}

    "}}}

  endfunction "}}}
endif "}}}

if Tap('neomru.vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:neomru#filename_format = ''
    let g:neomru#time_format = ''
    let g:neomru#do_validate = 0
    let g:neomru#file_mru_path = expand('$VIMFILES/tmp/.unite/file')
    let g:neomru#directory_mru_path = expand('$VIMFILES/tmp/.unite/directory')
  endfunction "}}}
endif "}}}

if Tap('neoyank.vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:neoyank#file = expand('$VIMFILES/tmp/.neoyank/history_yank')
    let g:neoyank#limit = 30
  endfunction "}}}
endif "}}}

if Tap('unite-everything') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:unite_source_everything_full_path_search=1
    let g:unite_source_everything_ignore_pattern = '\.\%(git\|hg\|svn\)'
    let g:unite_source_everything_limit = 1000
  endfunction "}}}
endif "}}}

if Tap('vimshell') "{{{

  nnoremap [Plug]ss :<C-u>VimShell -buffer-name=vimshell -toggle -popup<CR>
  nnoremap [Plug]sS :<C-u>VimShell -buffer-name=vimshell -toggle<CR>
  nnoremap [Plug]sb :<C-u>VimShellBufferDir -buffer-name=vimshell -toggle -popup<CR>
  nnoremap [Plug]sc :<C-u>VimShellCurrentDir -buffer-name=vimshell -toggle -popup<CR>

  nnoremap <Leader>ss :<C-u>VimShell -buffer-name=vimshell -toggle -popup<CR>
  nnoremap <Leader>sS :<C-u>VimShell -buffer-name=vimshell -toggle -split<CR>
  nnoremap <Leader>sb :<C-u>VimShellBufferDir -buffer-name=vimshell -toggle -popup<CR>
  nnoremap <Leader>sc :<C-u>VimShellCurrentDir -buffer-name=vimshell -toggle -popup<CR>
  nnoremap <Leader>st :<C-u>VimShellTab -buffer-name=vimshell -toggle<CR>

  function! neobundle#hooks.on_source(bundle) "{{{
    let g:vimshell_prompt='%>'
    let g:vimshell_secondary_prompt = '%%>'
    let g:vimshell_user_prompt = '"[".GetShortPath(getcwd(),4,40)."]"'
    let g:vimshell_right_prompt = '(exists("b:vimshell.system_variables.status")?b:vimshell.system_variables.status:"")."  ".strftime("%Y/%m/%d\ %X")'
    let g:vimshell_data_directory = expand('$VIMFILES/tmp/.vimshell')
    let g:vimshell_temporary_directory = g:vimshell_data_directory
    let g:vimshell_max_command_history = 2000
    " let g:vimshell_use_terminal_command='sh -il'
    let g:vimshell_vimshrc_path = expand('$VIMFILES/vimshrc')
    if filereadable(expand('$HOME/.zsh_history'))
      let g:unite_source_vimshell_external_history_path=expand('$HOME/.zsh_history')
    elseif filereadable(expand('$HOME/.bash_history'))
      let g:unite_source_vimshell_external_history_path=expand('$HOME/.bash_history')
    endif
    let g:vimshell_popup_height = 50
    let g:vimshell_scrollback_limit = 10000
    let g:vimshell_enable_stay_insert = 1
    let g:vimshell_force_overwrite_statusline = 0

    "vimshel StatusLine Settings"{{{
    function! VimshellGetPath() "{{{
      if !exists('b:vimshell')
        return ''
      endif
      return GetShortPath(get(b:vimshell, 'current_dir', ''), 4, 20)
    endfunction "}}}
    function! VimshellContinuation() "{{{
      if !exists('b:vimshell')
        return ''
      endif
      return empty(get(b:vimshell, 'continuation', {})) ? '' : '[async]'
    endfunction "}}}
    function! VimshellStatusLine() "{{{
      let l:ret =' '
      let l:ret.=StatusLineBufNum()
      let l:ret.='%#StatusLineModeMsgVl#[*%{Bufpath()}*]%*'
      let l:ret.='['
      let l:ret.='%{VimshellGetPath()}'
      let l:ret.=']'
      let l:ret.='%#Error#%{VimshellContinuation()}%*'
      let l:ret.='%#Error#%h%w%q%r%m%*'
      let l:ret.=StatuslineGetMode()
      let l:ret.='%<'
      let l:ret.='%='
      let l:ret.=StatuslineSuffix()
      return l:ret
    endfunction "}}}
    "}}}

    function! s:vimshell_settings() "{{{
      setlocal statusline=%!VimshellStatusLine()

      call UnmapBuffer('<C-n>', 'n')
      call UnmapBuffer('<C-p>', 'n')
      nnoremap <buffer> ? :<C-u>Mapping vimshell<CR>
      nmap <buffer> gj <Plug>(vimshell_next_prompt)
      nmap <buffer> gk <Plug>(vimshell_previous_prompt)

      nmap <buffer> <C-r> <Plug>(vimshell_clear)
      nmap <buffer> <C-b> <Plug>(vimshell_execute_by_background)
      nnoremap <silent><buffer> J <C-u>:Unite -default-action=lcd -no-split -buffer-name=directory_mru bookmark:directory directory_mru<CR>
      nnoremap <silent><buffer> <C-J> <C-u>:Unite -default-action=lcd -winheight=5 -buffer-name=directory_mru bookmark:directory directory_mru<CR>
      nmap <buffer> K <Plug>(vimshell_delete_previous_output)

      imap <buffer> <C-b> <Plug>(vimshell_execute_by_background)
      imap <buffer> jj <Esc>
      imap <buffer> kk <Esc>
      imap <buffer> <C-z> <Plug>(vimshell_zsh_complete)

      call vimshell#set_alias('ll', 'ls -lh')
      call vimshell#set_alias('la', 'ls -Ah')
      call vimshell#set_alias('l.', 'ls -d .*')
      call vimshell#set_alias('lla', 'ls -lAh')
      call vimshell#set_galias('$?', '$$status')

      call vimshell#altercmd#define('jv', 'jvgrep --exclude ''\.(git|svn|hg|bzr|jar$|zip$|exe$)'' -in8  param file')
      call vimshell#altercmd#define('be', 'bundle exec')
      call vimshell#altercmd#define('bi', 'bundle install --path vendor/bundler')
      call vimshell#altercmd#define('bgd', 'less --encoding=utf-8 --syntax=diff git diff')
      if g:is_windows
        call vimshell#set_alias('gitdiff', 'exe --encoding=cp932 git difftool --tool=gvimdiff --no-prompt')
      else
        call vimshell#set_alias('gitdiff', 'exe git difftool --tool=gvimdiff --no-prompt')
      endif

    endfunction "}}}
    autocmd MyAutoCmd FileType vimshell call s:vimshell_settings()
    autocmd MyAutoCmd FileType int-sqlplus call IndentSet(8)
    function! s:vimshell_less_Setting()
      call UnmapBuffer('<Space>', 'n')
    endfunction
    autocmd MyAutoCmd FileType vimshell-less call s:vimshell_less_Setting()
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    call Set_default('g:vimshell_terminal_commands', {})
    call extend(g:vimshell_terminal_commands, {'sh' : 1})

    call Set_default('g:vimshell_no_save_history_commands', {})
    call extend(g:vimshell_no_save_history_commands, {'cdup' : 1, 'pwd' : 1})

    call Set_default('g:vimshell_interactive_encodings', {})
    call extend(g:vimshell_interactive_encodings, {'sqlplus': 'utf-8'})
    call extend(g:vimshell_interactive_encodings, {'git': 'utf-8'})
    call extend(g:vimshell_interactive_encodings, {'vagrant': 'utf-8'})
  endfunction "}}}
endif "}}}

if Tap('neocomplete.vim') "{{{
  call neobundle#config({
    \   'on_cmd' : ['NeoCompleteBufferMakeCache', 'NeoCompleteEnable'],
    \   'on_i' : 1,
    \ })
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:neocomplete#enable_at_startup = 1

    let g:neocomplete#max_list = 30
    let g:neocomplete#max_keyword_width = 50
    let g:neocomplete#data_directory = expand('$VIMFILES/tmp/.neocomplete')
    let g:neocomplete#enable_ignore_case = 1
    let g:neocomplete#enable_smart_case = 0
    let g:neocomplete#sources#syntax#min_keyword_length = 2
    " Use camel case completion.
    "let g:neocomplete#enable_camel_case = 1
    let g:neocomplete#enable_fuzzy_completion = 1

    " 自動補完を行わないバッファ名
    let g:neocomplete#lock_buffer_name_pattern = '\.log\|.*quickrun.*\|.*vimshell.*\|.*;tail'
    " キャッシュしないファイル名
    let g:neocomplete#sources#buffer#disabled_pattern = g:neocomplete#lock_buffer_name_pattern
    let g:neocomplete#sources#buffer#disabled_pattern .= '\|__scratch__.*'

    if has('reltime')
      let g:neocomplete#skip_auto_completion_time = '0.5'
    endif
    call Set_default('g:neocomplete#sources#omni#functions', {})
    let g:neocomplete#sources#omni#functions = {
      \ 'html' : 'emmet#completeTag',
      \ 'css' : 'emmet#completeTag',
      \ 'javascript' : 'emmet#completeTag',
      \ }

    " ディクショナリ定義
    let g:neocomplete#sources#dictionary#dictionaries = { 'default' : '' }
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'html' : $VIMDICT.'/html.dict'.','.$VIMDICT.'/jquery.dict'.','.$VIMDICT.'/javascript.dict'.','.$VIMDICT.'/css.dict'})
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'javascript' : $VIMDICT.'/jquery.dict'.','.$VIMDICT.'/javascript.dict' })
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'css' : $VIMDICT.'/css.dict' })
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'autohotkey' : $VIMDICT.'/ahk.dict' })
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'dosbatch' : $VIMDICT.'/dosbatch.dict' })
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'sql' : $VIMDICT.'/sql.dict' })
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'cobol' : $VIMDICT.'/COBOL.dict' })
    call extend(g:neocomplete#sources#dictionary#dictionaries, { 'ruby' : $VIMDICT.'/ruby.dict' })

    let g:neocomplete#sources#vim#complete_functions = {
      \ 'Unite' : 'unite#complete_source',
      \ 'Ref' : 'ref#complete',
      \ 'VimShellExecute' : 'vimshell#vimshell_execute_complete',
      \ 'VimShellInteractive' : 'vimshell#vimshell_execute_complete',
      \ 'VimShell' : 'vimshell#complete',
      \ 'VimFiler' : 'vimfiler#complete',
      \ 'VimFilerBufferDir' : 'vimfiler#complete',
      \ 'VimFilerCurrentDir' : 'vimfiler#complete',
      \ 'VimFilerDouble' : 'vimfiler#complete',
      \ 'VimFilerExplorer' : 'vimfiler#complete',
      \ 'VimFilerSimple' : 'vimfiler#complete',
      \ 'VimFilerSplit' : 'vimfiler#complete',
      \ 'VimFilerTab' : 'vimfiler#complete',
      \ 'Edit' : 'vimfiler#complete',
      \ 'QuickRun' : 'quickrun#complete',
      \ 'Template' : 'sonictemplate#complete',
      \ 'PP' : 'var',
      \ 'PrettyPrint' : 'var',
      \ 'Capture' : 'command',
      \ 'Ipmsg' : 'GetHostName',
      \ }

  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    " 選択している候補を確定
    imap <expr><C-y> pumvisible() ? neocomplete#close_popup() : "\<C-y>"
    "imap <expr><CR> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplete#close_popup() : "\<CR>"
    imap <expr><CR> neosnippet#expandable() ? "\<Plug>(neosnippet_expand)<Esc>gv" :
      \ neosnippet#jumpable() ? "\<Plug>(neosnippet_jump)" :
      \ pumvisible() ? neocomplete#close_popup() :
      \ "\<CR>"
    imap <expr><C-k> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? neocomplete#close_popup() : "\<Del>"

    "C-h, BSで補完ウィンドウを確実に閉じる
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<BS>"
    " 現在選択している候補をキャンセルし、ポップアップを閉じます
    inoremap <expr><C-e> pumvisible() ? neocomplete#cancel_popup() : "\<C-e>"
    " 共通部分を確定させる
    inoremap <expr><C-l> neocomplete#complete_common_string()

    " uniteによる保管を行う
    imap <C-f> <Plug>(neocomplete_start_unite_complete)
    imap <C-Space> <Plug>(neocomplete_start_unite_complete)

    "vim標準のキーワード補完を置き換える
    inoremap <expr><C-n> pumvisible() ? "\<C-n>" : neocomplete#start_manual_complete()
    "inoremap <expr><C-x><C-n> pumvisible() ? "\<C-n>" : neocomplete#manual_keyword_complete()
    "inoremap <expr><C-Space> neocomplete#manual_keyword_complete()
    "オムニ補完の手動呼び出し
    "inoremap <expr><C-x><C-o> neocomplete#manual_omni_complete()
    "inoremap <expr><C-x><C-o> &filetype == 'vim' ? "\<C-x><C-v><C-p>" : neocomplete#manual_omni_complete()

    "inoremap <expr><TAB> pumvisible() ? "\<Down>" : neocomplete#start_manual_complete()

    "tabで補完候補の選択を行う
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<S-TAB>"

  endfunction "}}}
endif "}}}

if Tap('vim-precious') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:precious_enable_switch_CursorMoved = {
      \   '*' : 0,
      \   'html' : 1,
      \   'xhtml' : 1,
      \   'markdown' : 1,
      \   'css' : 1,
      \   'javascript' : 1,
      \   'cobol' : 1,
      \   'vim' : 1,
      \ }
    let g:precious_enable_switch_CursorMoved_i = g:precious_enable_switch_CursorMoved
  endfunction "}}}
endif "}}}

if Tap('context_filetype.vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:context_filetype#search_offset = 300 "3000
    let g:context_filetype#filetypes = {
      \   'cobol': [
      \     { 'start' : '^ *EXEC SQL$',
      \       'end' : '^ *END-EXEC$',
      \       'filetype' : 'sqloracle', },
      \     { 'start' : '^ *EXEC SQL.*CURSOR FOR$',
      \       'end' : '^ *END-EXEC$',
      \       'filetype' : 'sqloracle', },
      \   ],
      \   'html': [
      \     { 'start' : '<script\%( [^>]*\)\? type="text/\(\h\w*\)"\%( [^>]*\)\?>',
      \       'end' : '</script>',
      \       'filetype' : '\1', },
      \     { 'start' : '<script\%( [^>]*\)\?>',
      \       'end' : '</script>',
      \       'filetype' : 'javascript', },
      \     { 'start' : '<style\%( [^>]*\)\? type="text/css"\%( [^>]*\)\?>',
      \       'end' : '</style>',
      \       'filetype' : 'css', },
      \   ],
      \ }

 endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
  endfunction "}}}
endif "}}}

if Tap('neosnippet') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:neosnippet#disable_select_mode_mappings=1
    let g:neosnippet#snippets_directory = expand('$VIMFILES/snippets')
    let g:neosnippet_data_directory = expand('$VIMFILES/tmp/.neosnippet')
    let g:neosnippet#data_directory = expand('$VIMFILES/tmp/.neosnippet')
    let g:neosnippet#enable_snipmate_compatibility = 1
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    imap <C-s> <Plug>(neosnippet_start_unite_snippet)*
  endfunction "}}}
endif "}}}

if Tap('sonictemplate-vim') "{{{
  imap <c-t>t <C-o><plug>(sonictemplate)
  imap <c-t><c-t> <C-R>=unite#start_complete(['sonictemplate'], unite#get_profile('completion', 'context'))<Cr>
  function! neobundle#hooks.on_source(bundle) "{{{
    " disabled default mapping.
    let g:sonictemplate_key = '<plug>(sonictemplate)'
    let g:sonictemplate_intelligent_key = '<plug>(sonictemplate-intelligent)'
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    " imap <c-t>t <plug>(sonictemplate)
    " imap <c-t><c-t> <plug>(sonictemplate)
    " imap <c-t>T <plug>(sonictemplate-intelligent)
    imap <c-t>t <plug>(sonictemplate)
  endfunction "}}}
endif "}}}

if Tap('emmet-vim') "{{{
  nnoremap [emmet] <Nop>
  inoremap [emmet] <Nop>
  vnoremap [emmet] <Nop>
  nmap <C-Return> [emmet]
  imap <C-Return> [emmet]
  vmap <C-Return> [emmet]
  nnoremap <silent> [emmet]? :Mapping [emmet]<CR>
  autocmd MyAutoCmd FileType xhtml,html,css,javascript setlocal omnifunc=emmet#completeTag

  function! neobundle#hooks.on_source(bundle) "{{{
    let g:user_emmet_leader_key = '[emmet]'
    let g:use_emmet_complete_tag = 1
    let g:user_emmet_mode='a'

    "g:user_emmet_settings {{{
    let g:user_emmet_settings = {
      \   'lang' : 'ja',
      \   'indentation' : '  ',
      \   'charset' : 'utf-8',
      \   'html' : {
      \     'snippets': {
      \       'jq' : "\\$(document).ready( function() {\n\t|\n});",
      \       'jq:s' : "\\\$(|)",
      \       'jq:si' : "\\\$('#|')",
      \       'jq:sc' : "\\\$('.|')",
      \       'jq:sn' : "\\\$('[name=\"|\"]')",
      \     },
      \   },
      \ }
    "}}}
  endfunction "}}}
endif "}}}

let s:installed_vim_ambicmd = Tap('vim-ambicmd')
if s:installed_vim_ambicmd "{{{
  cnoremap <expr> <Space> ambicmd#expand("\<Space>")
  cnoremap <expr> <CR>    ambicmd#expand("\<CR>")
endif "}}}

if Tap('poshcomplete-vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    autocmd MyAutoCmd FileType ps1 setlocal omnifunc=poshcomplete#CompleteCommand
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    call poshcomplete#StartServer()
  endfunction "}}}
endif "}}}

if Tap('neco-syntax') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:necosyntax#min_keyword_length=2
  endfunction "}}}
endif "}}}

if Tap('neco-vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:necovim#complete_functions = {
      \ 'Unite' : 'unite#complete_source',
      \ 'Ref' : 'ref#complete',
      \ 'VimShellExecute' : 'vimshell#vimshell_execute_complete',
      \ 'VimShellInteractive' : 'vimshell#vimshell_execute_complete',
      \ 'VimShell' : 'vimshell#complete',
      \ 'VimFiler' : 'vimfiler#complete',
      \ 'VimFilerBufferDir' : 'vimfiler#complete',
      \ 'VimFilerCurrentDir' : 'vimfiler#complete',
      \ 'VimFilerDouble' : 'vimfiler#complete',
      \ 'VimFilerExplorer' : 'vimfiler#complete',
      \ 'VimFilerSimple' : 'vimfiler#complete',
      \ 'VimFilerSplit' : 'vimfiler#complete',
      \ 'VimFilerTab' : 'vimfiler#complete',
      \ 'Edit' : 'vimfiler#complete',
      \ 'QuickRun' : 'quickrun#complete',
      \ 'Template' : 'sonictemplate#complete',
      \ 'PP' : 'var',
      \ 'PrettyPrint' : 'var',
      \ 'Capture' : 'command',
      \ }
  endfunction "}}}
endif "}}}

if Tap('vimfiler') "{{{

  "vimfiler prefix key.
  nnoremap [vimfiler] <Nop>
  nmap <Leader>f [vimfiler]
  nmap <Leader>F [vimfiler]
  nnoremap [vimfiler]? :<C-u>Mapping [vimfiler]<CR>

  nnoremap <silent> [vimfiler]f :<C-u>VimFiler -buffer-name=ff -horizontal <CR>
  nnoremap <silent> [vimfiler]F :<C-u>VimFiler -buffer-name=ff -no-split<CR>
  nnoremap <silent> [vimfiler]t :<C-u>VimFilerTab<CR>
  nnoremap <silent> [vimfiler]s :<C-u>VimFiler -buffer-name=fs -simple<CR>

  nnoremap <silent> [vimfiler]b :<C-u>VimFilerBufferDir -buffer-name=fb -horizontal<CR>
  nnoremap <silent> [vimfiler]B :<C-u>VimFilerBufferDir -buffer-name=fb<CR>
  nnoremap <silent> [vimfiler]c :<C-u>VimFilerCurrentDir -buffer-name=fc -horizontal<CR>
  nnoremap <silent> [vimfiler]C :<C-u>VimFilerCurrentDir -buffer-name=fc<CR>
  nnoremap <silent> [vimfiler]d :<C-u>VimFilerDouble -buffer-name=fd -split -toggle -no-quit<CR>
  nnoremap <silent> [vimfiler]D :<C-u>VimFilerDouble -buffer-name=fd -split -horizontal -toggle -no-quit<CR>

  nnoremap <silent> [vimfiler]v :<C-u>VimFilerBufferDir -buffer-name=fv -simple<CR>
  nnoremap <silent> [vimfiler]V :<C-u>VimFilerCurrentDir -buffer-name=fv -simple<CR>
  nnoremap <silent> [vimfiler]e :<C-u>VimFilerBufferDir -buffer-name=fe -explorer -direction=topleft -winwidth=30 -winheight=0<CR>
  nnoremap <silent> [vimfiler]E :<C-u>VimFilerCurrentDir -buffer-name=fe -explorer -direction=topleft -winwidth=30 -winheight=0<CR>
  command! MemoExplorer execute 'VimFilerExplorer -winwidth=30 -direction=topleft '.g:memo_dir

  function! neobundle#hooks.on_source(bundle) "{{{
    let g:vimfiler_as_default_explorer = 1
    let g:vimfiler_data_directory = expand('$VIMFILES/tmp/.vimfiler')
    let g:unite_kind_file_use_trashbox = 1
    let g:vimfiler_force_overwrite_statusline = 0

    let g:vimfiler_tree_leaf_icon = '|'
    let g:vimfiler_tree_opened_icon = '-'
    let g:vimfiler_tree_closed_icon = '+'
    if has('gui_running')
      let g:vimfiler_tree_opened_icon = nr2char(9662, 1) "'▾'
      let g:vimfiler_tree_closed_icon = nr2char(9656, 1) "'▸'
    endif
    let g:vimfiler_file_icon = ' '

    "VimFiler StatusLine Settings"{{{
    function! VimFilerSafeMode() "{{{
      return exists('b:vimfiler') ? get(b:vimfiler, 'is_safe_mode') : 0
    endfunction "}}}
    function! VimFilerMask() "{{{
      if exists('b:vimfiler')
        let l:current_mask = get(b:vimfiler, 'current_mask', '')
        if !empty(l:current_mask)
          return '['.l:current_mask.']'
        endif
      endif
      return ''
    endfunction "}}}
    function! VimFilerPath() "{{{
      if exists('b:vimfiler')
        return GetShortPath(get(b:vimfiler, 'current_dir', getcwd()), 4, 20)
      else
        return ''
      endif
    endfunction "}}}
    function! VimFilerLineCount() "{{{
      if !exists('b:vimfiler')
        return ''
      endif
      let l:all_files_len = get(b:vimfiler, 'all_files_len')
      let l:prompt_linenr = get(b:vimfiler, 'prompt_linenr')
      let l:len = len(l:all_files_len)
      return printf('%'.l:len.'d/%'.l:len.'d', line('.') - l:prompt_linenr, l:all_files_len)
    endfunction "}}}
    function! VimFilerStatusLine() "{{{
      let l:ret =' '
      let l:ret.=StatusLineBufNum()
      let l:ret.='%#StatusLineModeMsgVl#[*%{Bufpath()}*]%*'
      let l:ret.=' '
      let l:ret.='%#Error#%{VimFilerSafeMode()?"":"[    ]"}%*'
      let l:ret.='%{VimFilerSafeMode()?"[safe]":""}'
      let l:ret.='['
      let l:ret.='%{VimFilerPath()}'
      let l:ret.=']'
      let l:ret.='%#Search#%{VimFilerMask()}%*'
      let l:ret.='[%{VimFilerLineCount()}]'
      let l:ret.='%#Error#%h%w%q%r%m%*'
      let l:ret.=StatuslineGetMode()
      let l:ret.='%<'
      let l:ret.='%='
      let l:ret.=StatuslineSuffix()
      return l:ret
    endfunction "}}}
    "}}}

    function! s:vimfiler_my_settings() "{{{
      setl cursorline
      setl statusline=%!VimFilerStatusLine()

      call UnmapBuffer('<Space>', 'n')
      call UnmapBuffer('<S-Space>', 'n')
      call UnmapBuffer('<Tab>', 'n')
      "nmap <buffer> <expr> <CR> vimfiler#smart_cursor_map("\<Plug>(vimfiler_expand_tree)", "\<Plug>(vimfiler_edit_file)")
      nmap <buffer> ss <Plug>(vimfiler_toggle_mark_current_line)
      nmap <buffer> SS <Plug>(vimfiler_toggle_mark_current_line_up)
      nmap <buffer> S<CR> <Plug>(vimfiler_select_sort_type)
      nmap <buffer> <C-j> <Plug>(vimfiler_switch_to_history_directory)
      nnoremap <silent><buffer> J <C-u>:Unite -default-action=lcd -buffer-name=directory_mru bookmark:directory directory_mru<CR>
      nmap <buffer> A <Plug>(vimfiler_toggle_maximize_window)
      nmap <buffer> cc <Plug>(vimfiler_copy_file)
      nmap <buffer> mm <Plug>(vimfiler_move_file)
      nmap <buffer> dd <Plug>(vimfiler_delete_file)
      nmap <buffer> D <Plug>(vimfiler_delete_file)
      nmap <buffer> <C-r> <Plug>(vimfiler_redraw_screen)
      nmap <buffer> <C-h> <Plug>(vimfiler_switch_to_parent_directory)
      nmap <buffer> ? <Plug>(vimfiler_help)
      nmap <buffer> o <Plug>(vimfiler_expand_or_edit)
      nmap <buffer> go <Plug>(vimfiler_open_file_in_another_vimfiler)
      nnoremap <buffer> <Leader>/ :<C-u>Unite -buffer-name=search line:all<CR>
      "nmap <buffer> <C-Return> <Plug>(vimfiler_execute_vimfiler_associated)
      if g:is_windows
        nnoremap <buffer><expr> <C-Return> vimfiler#do_action('office_readonly')
        nnoremap <buffer><expr> <C-S-Return> vimfiler#do_action('contextmenu')
      endif
      nnoremap <buffer><expr> T vimfiler#do_action('tabopen')

      "nnoremap <silent><buffer><expr> v vimfiler#do_switch_action('vsplit')
      nmap <buffer><expr> e vimfiler#smart_cursor_map(
        \  "\<Plug>(vimfiler_cd_file)",
        \  "\<Plug>(vimfiler_edit_file)")

      hi vimfilerClosedFile term=bold cterm=bold ctermfg=7 gui=bold guifg=SlateGray
      " hi vimfilerOpenedFile term=bold cterm=bold ctermfg=7 gui=bold guifg=Red
    endfunction "}}}
    autocmd MyAutoCmd FileType vimfiler call s:vimfiler_my_settings()

  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{

    nmap <Leader>f [vimfiler]
    call extend(vimfiler#custom#get(), {'profiles': {
      \   'default': {'context' : {},}, 'ff': {'context' : {},},
      \   'fs': {'context' : {},}, 'fv': {'context' : {},}, 'fe': {'context' : {},},
      \   'fb': {'context' : {},}, 'fc': {'context' : {},},
      \ }})

    let l:context = {
      \   'auto_cd': 1,
      \   'direction': 'botright',
      \   'edit_action': 'open',
      \   'no_quit': 1,
      \   'safe': 1,
      \   'split_action': 'vsplit',
      \   'split_rule': 'botright',
      \   'status': 1,
      \   'split': '1',
      \   'toggle': 1,
      \   'winheight': 0,
      \   'winwidth': 0,
      \   'explorer': 0,
      \   'simple' : 1,
      \ }

    call vimfiler#custom#profile('default', 'context', deepcopy(l:context, 1))
    call vimfiler#custom#profile('ff', 'context', extend(deepcopy(l:context, 1), {
      \   'horizontal' : 1,
      \ }))
    call vimfiler#custom#profile('fs', 'context', extend(deepcopy(l:context, 1), {
      \   'simple' : 1,
      \   'horizontal' : 1,
      \   'direction': 'topleft',
      \   'split_rule': 'leftabove',
      \ }))
    call vimfiler#custom#profile('fb', 'context', extend(deepcopy(l:context, 1), {
      \   'direction': 'topleft',
      \   'split_rule': 'topleft',
      \   'split_action': 'vsplit',
      \ }))
    call vimfiler#custom#profile('fc', 'context', extend(deepcopy(l:context, 1), {
      \   'direction': 'topleft',
      \   'split_rule': 'leftabove',
      \ }))
    call vimfiler#custom#profile('fv', 'context', extend(deepcopy(l:context, 1), {
      \   'simple' : 1,
      \   'split': 1,
      \   'split_action' : 'vsplit',
      \   'split_rule': 'leftabove',
      \   'direction': 'leftabove',
      \   'winminwidth' : 15,
      \   'winwidth' : 30,
      \ }))
    call vimfiler#custom#profile('fe', 'context', extend(deepcopy(l:context, 1), {
      \   'explorer' : 1,
      \   'explorer_columns': '',
      \   'direction': 'leftabove',
      \   'simple' : 1,
      \   'split': 1,
      \   'split_action' : 'split',
      \   'winwidth' : 30,
      \ }))

    call vimfiler#set_execute_file('_', 'vim')
  endfunction "}}}
endif "}}}

if Tap('which.vim') "{{{
  function! s:defWhichCommand() abort
    command! -nargs=1 Which echo Which(<q-args>)
  endfunction
  function! neobundle#hooks.on_post_source(bundle) "{{{
    call s:defWhichCommand()
  endfunction "}}}
  call s:defWhichCommand()
endif "}}}

if Tap('capture.vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:capture_open_command = 'vert new'
  endfunction "}}}
endif "}}}

if Tap('nerdcommenter') "{{{
  "mappings{{{
  "Comment map
  map [Plug]CC <plug>NERDCommenterComment
  ounmap [Plug]CC

  " Nested
  map [Plug]cn <plug>NERDCommenterNested
  ounmap [Plug]cn

  "Toggle comment map
  map [Plug]cc <plug>NERDCommenterToggle
  ounmap [Plug]cc
  map <Leader>cc <plug>NERDCommenterToggle
  ounmap <Leader>cc

  "Minimal comment map
  map [Plug]cm <plug>NERDCommenterMinimal
  ounmap [Plug]cm
  map <Leader>cm <plug>NERDCommenterMinimal
  ounmap <Leader>cm

  "Invert comment map
  map [Plug]ci <plug>NERDCommenterInvert
  ounmap [Plug]ci

  "Sexy comment map
  map [Plug]cs <plug>NERDCommenterSexy
  ounmap [Plug]cs

  "Yank comment map
  map [Plug]cy <plug>NERDCommenterYank
  ounmap [Plug]cy

  "Comment to EOL map
  nmap [Plug]c$ <plug>NERDCommenterToEOL

  "Append com to line map
  nmap [Plug]cA <plug>NERDCommenterAppend

  "Insert comment map
  imap [Plug]cc <plug>NERDCommenterInsert

  "Use alternate delims map
  nmap [Plug]ca <plug>NERDCommenterAltDelims

  "Comment aligned maps
  map [Plug]cl <plug>NERDCommenterAlignLeft
  ounmap [Plug]cl
  map [Plug]cb <plug>NERDCommenterAlignBoth
  ounmap [Plug]cb

  "Uncomment line map
  map [Plug]cu <plug>NERDCommenterUncomment
  ounmap [Plug]cu
  "}}}
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:NERDMenuMode = 0 "Menu off
    let g:NERDCreateDefaultMappings = 0
    let g:NERDRemoveExtraSpaces = 1
    let g:NERDSpaceDelims = 1
    let g:NERDCustomDelimiters = {
      \   'dosbatch': {'left': 'REM', 'leftAlt': '::', 'right': '', 'rightAlt': ''},
      \   'sql' : {'left': '--', 'leftAlt': '/*', 'rightAlt': '*/', },
      \   'autohotkey' : {'left': ';', 'leftAlt': '/*', 'rightAlt': '*/'},
      \ }
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    doautoall NERDCommenter BufEnter
  endfunction "}}}
endif "}}}

if Tap('vim-rectinsert') "{{{
  nmap <silent> [Plug]P <Plug>(rectinsert_insert)
  vmap <silent> [Plug]P <Plug>(rectinsert_insert)
  nmap <silent> [Plug]p <Plug>(rectinsert_append)
  vmap <silent> [Plug]p <Plug>(rectinsert_append)
endif "}}}

if Tap('switch.vim') "{{{
  nnoremap [Plug]to :<C-u>Switch<CR>
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:switch_custom_definitions = [
      \   ['yes', 'no'],
      \   ['on', 'off'],
      \   ["月", '火', '水', '木', '金', '土', '日'],
      \   ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      \   ['public', 'protected', 'private'],
      \ ]
  endfunction "}}}
endif "}}}

if Tap('vim-surround') "{{{
  xmap S   <Plug>VSurround
  nmap cs  <Plug>Csurround
  nmap ds  <Plug>Dsurround
  xmap gS  <Plug>VgSurround
  nmap ySS <Plug>YSsurround
  nmap ySs <Plug>YSsurround
  nmap yss <Plug>Yssurround
  nmap yS  <Plug>YSurround
  nmap ys  <Plug>Ysurround
endif "}}}

if Tap('Align') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:DrChipTopLvlMenu = ""
    let g:Align_xstrlen = 3
  endfunction "}}}
endif "}}}

if Tap('vim-quickhl') "{{{
  nmap [Plug]h <Plug>(quickhl-manual-this)
  vmap [Plug]h <Plug>(quickhl-manual-this)
  nmap [Plug]H <Plug>(quickhl-manual-reset)
  vmap [Plug]H <Plug>(quickhl-manual-reset)
  nmap [Plug]j <Plug>(quickhl-cword-toggle)

  function! neobundle#hooks.on_source(bundle) "{{{
    let g:quickhl_manual_hl_priority = 20
    let g:quickhl_manual_colors = []
    call add(g:quickhl_manual_colors, "gui=bold guifg=#ffffff guibg=#0a7383")
    call add(g:quickhl_manual_colors, "gui=bold guifg=#ffffff guibg=#a07040")
    call add(g:quickhl_manual_colors, "gui=bold guifg=#ffffff guibg=#4070a0")
    "To highlight some keyword always,
    "let g:quickhl_keywords = [ "TODO", "CAUTION", "ERROR" ]
  endfunction "}}}
endif "}}}

if Tap('vim-textmanip') "{{{
  "mappings{{{
  nmap gY <Plug>(textmanip-duplicate-down)
  xmap gY <Plug>(textmanip-duplicate-down)
  nmap gy <Plug>(textmanip-duplicate-up)
  xmap gy <Plug>(textmanip-duplicate-up)

  nmap <M-Down> V<Plug>(textmanip-move-down)<Esc>
  nmap <M-Up> V<Plug>(textmanip-move-up)<Esc>
  nmap <M-Left> V<Plug>(textmanip-move-left)<Esc>
  nmap <M-Right> V<Plug>(textmanip-move-right)<Esc>

  xmap <M-Down> <Plug>(textmanip-move-down)
  xmap <M-Up> <Plug>(textmanip-move-up)
  xmap <M-Left> <Plug>(textmanip-move-left)
  xmap <M-Right> <Plug>(textmanip-move-right)
  "}}}
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:textmanip_enable_mappings = 0
    let g:textmanip_startup_mode='insert'
    let g:textmanip_current_mode='insert'
  endfunction "}}}
endif "}}}

if Tap('vim-choosewin') "{{{
  map <LocalLeader>, <Plug>(choosewin)
  map <Leader>o <Plug>(choosewin)
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:choosewin_label = 'jkhlyuiop'
    let g:choosewin_tablabel = '123456789'
    let g:choosewin_blink_on_land = 0
    let g:choosewin_label_fill = 0
    let g:choosewin_return_on_single_win = 0
    let g:choosewin_tabline_replace = 0
    let g:choosewin_color_label = {
      \   'cterm': [22, 15, 'bold'],
      \   'gui': ['DarkGreen', 'white', 'bold']
      \ }

  endfunction "}}}
endif "}}}

if Tap('vim-indent-guides') "{{{
  nmap [Plug]ig <Plug>IndentGuidesToggle
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:indent_guides_default_mapping = 0
    let g:indent_guides_enable_on_vim_startup=1
    let g:indent_guides_guide_size=0
    let g:indent_guides_indent_levels = 10
    let g:indent_guides_exclude_filetypes = ['help', 'unite', 'vimfiler', 'vimshell', 'log', 'text', 'calendar', 'vimcalc', 'ref', 'quickrun', 'tail']
    let g:indent_guides_start_level = 1

    let g:indent_guides_auto_colors = 0
    autocmd MyAutoCmd Colorscheme * call s:indentGuidesColor()
    function! s:indentGuidesColor() "{{{
      if &background == 'light'
        highlight IndentGuidesOdd  guibg=grey95 ctermbg=233
        highlight IndentGuidesEven guibg=grey90 ctermbg=235
      else
        highlight IndentGuidesOdd  guibg=grey15 ctermbg=darkgrey
        highlight IndentGuidesEven guibg=grey5 ctermbg=black
      endif
    endfunction "}}}
    call s:indentGuidesColor()

  endfunction "}}}
endif "}}}

if Tap('number-marks') "{{{
  nmap mm <Plug>Place_sign
  nmap mn <Plug>Goto_next_sign
  nmap mp <Plug>Goto_prev_sign
  nmap md <Plug>Remove_all_signs
  nmap ma <Plug>Move_sign
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:Signs_file_path_corey = expand('$VIMFILES/tmp/.number_marks/')
    let g:mapF5 =  maparg('<F5>', '', 0, 1)
    let g:mapF6 =  maparg('<F6>', '', 0, 1)
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    try
      "noremap <F6> :call SaveP()<cr>
      "noremap <F5> :call ReloadP()<cr>
      unmap <F5>
      unmap <F6>
    catch /^Vim\%((\a\+)\)\=:E31/
    endtry
    let l:V = VitalWrapper('Mapping')
    if !empty(g:mapF5)
      call l:V.Mapping.execute_map_command(g:mapF5.mode, g:mapF5, g:mapF5.lhs, g:mapF5.rhs)
    endif
    unlet g:mapF5
    if !empty(g:mapF6)
      call l:V.Mapping.execute_map_command(g:mapF6.mode, g:mapF6, g:mapF6.lhs, g:mapF6.rhs)
    endif
    unlet g:mapF6
    unlet l:V
    command! ThisSign exe 'sign place buffer=' . winbufnr(0)
  endfunction "}}}
endif "}}}

if Tap('colorizer') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:colorizer_nomap = 1
  endfunction "}}}
endif "}}}

if Tap('vim-anzu') "{{{
  nmap n <Plug>(anzu-n-with-echo)
  nmap N <Plug>(anzu-N-with-echo)
  nmap * <Plug>(anzu-star)
  nmap # <Plug>(anzu-sharp)
  nmap g* g*<Plug>(anzu-update-search-status-with-echo)
  nmap g# g#<Plug>(anzu-update-search-status-with-echo)
  function! neobundle#hooks.on_post_source(bundle) "{{{
    nnoremap <silent> <Plug>(C-o) <C-o>
    nnoremap <silent> <Plug>(zz) zz
    nmap n <Plug>(anzu-n-with-echo)<Plug>(zz)
    nmap N <Plug>(anzu-N-with-echo)<Plug>(zz)
    nmap * <Plug>(anzu-star)<Plug>(C-o)<Plug>(zz)
    nmap # <Plug>(anzu-sharp)<Plug>(C-o)<Plug>(zz)
    nmap g* g*<Plug>(anzu-update-search-status-with-echo)<Plug>(C-o)<Plug>(zz)
    nmap g# g#<Plug>(anzu-update-search-status-with-echo)<Plug>(C-o)<Plug>(zz)
    "nmap <silent> <Esc> <Plug>(anzu-clear-search-status)
    if g:is_windows || has('gui_running')
      nnoremap <silent> <Esc> :<C-u>AnzuClearSearchStatus<CR>:nohlsearch<CR><Esc>
    else
      nnoremap <silent> <Esc><Esc> :<C-u>AnzuClearSearchStatus<CR>:nohlsearch<CR><Esc>
    endif
  endfunction "}}}
endif "}}}

if Tap('vim-easymotion') "{{{
  map s <Plug>(easymotion-prefix)
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:EasyMotion_leader_key="s"
    let g:EasyMotion_grouping=1
    let g:EasyMotion_keys='jkhlasdfgyuiopqwertnmzxcvbJKHL'
    let g:EasyMotion_use_migemo = 1
  endfunction "}}}
endif "}}}

if Tap('clever-f.vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:clever_f_smart_case = 1
    let g:clever_f_use_migemo = 1

    let g:clever_f_mark_char = 1
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    map : <Plug>(clever-f-repeat-forward)
  endfunction "}}}
endif "}}}

if Tap('matchit.zip') "{{{
  function! neobundle#hooks.on_post_source(bundle) "{{{
    silent! execute 'doautocmd Filetype ' &filetype
  endfunction "}}}
endif "}}}

if Tap('vim-milfeulle') "{{{
  nmap <C-o> <Plug>(milfeulle-prev)
  nmap <C-i> <Plug>(milfeulle-next)
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:milfeulle_default_jumper_name = 'win_tab_bufnr_pos_line'
    let g:milfeulle_default_kind = 'window'
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    nnoremap <silent> <Plug>(dzz) <C-d>zz
    nnoremap <silent> <Plug>(uzz) <C-u>zz
    nmap <C-d> <Plug>(milfeulle-overlay)<Plug>(dzz)
    nmap <C-u> <Plug>(milfeulle-overlay)<Plug>(uzz)
  endfunction "}}}
endif "}}}

if Tap('vim-textobj-fold') "{{{
  xmap az  <Plug>(textobj-fold-a)
  omap az  <Plug>(textobj-fold-a)
  xmap iz  <Plug>(textobj-fold-i)
  omap iz  <Plug>(textobj-fold-i)
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:textobj_fold_no_default_key_mappings = 1
  endfunction "}}}
endif "}}}

if Tap('vim-textobj-indent') "{{{
  xmap ai <Plug>(textobj-indent-a)
  omap ai <Plug>(textobj-indent-a)
  xmap ii <Plug>(textobj-indent-i)
  omap ii <Plug>(textobj-indent-i)
  xmap aI <Plug>(textobj-indent-same-a)
  omap aI <Plug>(textobj-indent-same-a)
  xmap iI <Plug>(textobj-indent-same-i)
  omap iI <Plug>(textobj-indent-same-i)
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:textobj_indent_no_default_key_mappings = 1
  endfunction "}}}
endif "}}}

if Tap('vim-textobj-multiblock') "{{{
  omap ab <Plug>(textobj-multiblock-a)
  omap ib <Plug>(textobj-multiblock-i)
  xmap ab <Plug>(textobj-multiblock-a)
  xmap ib <Plug>(textobj-multiblock-i)
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:textobj_multiblock_blocks = [
      \   [ '`', '`' ],
      \   [ '\t', '\t' ],
      \   [ '%', '%', 1],
      \   [ '|', '|' ,1],
      \   [ '*', '*' ,1],
      \   [ '+', '+' ,1],
      \   [ '（', '）', 1],
      \   [ '「', '」', 1],
      \   [ '【', '】', 1],
      \ ]
  endfunction "}}}
endif "}}}

if Tap('vim-textobj-between') "{{{
  omap af <Plug>(textobj-between-a)
  xmap af <Plug>(textobj-between-a)
  omap if <Plug>(textobj-between-i)
  xmap if <Plug>(textobj-between-i)
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:textobj_between_no_default_key_mappings=1
  endfunction "}}}
endif "}}}

if Tap('vim-operator-replace') "{{{
  map <LocalLeader>r <Plug>(operator-replace)
endif "}}}

if Tap('operator-camelize.vim') "{{{
  map <LocalLeader>tc <Plug>(operator-camelize-toggle)
  map <LocalLeader>c <Plug>(operator-camelize)
  map <LocalLeader>C <Plug>(operator-decamelize)
endif "}}}

if Tap('operator-html-escape.vim') "{{{
  map <LocalLeader>he <Plug>(operator-html-escape)
  map <LocalLeader>hue <Plug>(operator-html-unescape)
  map <LocalLeader>e <Plug>(operator-html-escape)
  map <LocalLeader>ue <Plug>(operator-html-unescape)
endif "}}}

if Tap('im_control.vim') "{{{
  " 「日本語入力固定モード」切替キー
  inoremap <silent> <C-j> <C-^><C-r>=IMState('FixMode')<CR>
  function! neobundle#hooks.on_source(bundle) "{{{
    " 「日本語入力固定モード」の全バッファローカルモード
    let g:IM_CtrlBufLocalMode = 1
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    let l:V = VitalWrapper('Vim.ScriptLocal')
    let s:sfuncs = l:V.Vim.ScriptLocal.sfuncs((a:bundle.rtp).'/plugin/im_control.vim')
    augroup InsertHookIM_Cmdwin
      autocmd!
      autocmd CmdwinEnter * call s:sfuncs.BufEnter()
      autocmd CmdwinLeave * call s:sfuncs.BufLeave()
    augroup END
  endfunction "}}}
endif "}}}

if Tap('vim-capslock') "{{{
  nmap [Plug]ca <Plug>CapsLockToggle
  imap [Plug]ca <C-o><Plug>CapsLockToggle
  cmap [Plug]ca <Plug>CapsLockToggle

  command! CapsLockToggle execute 'normal <Plug>CapsLockToggle'
  command! CapsLockEnable execute 'normal <Plug>CapsLockEnable'
  command! CapsLockDisable execute 'normal <Plug>CapsLockDisable'
  function! neobundle#hooks.on_source(bundle) "{{{
    " exe printf('autocmd MyAutoCmd FileType %s CapsLockEnable',
    " \ join(g:capslock_filetype, ','))
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    " execute 'doautocmd Filetype ' &filetype
    autocmd! capslock InsertLeave
    autocmd! capslock CursorHold
  endfunction "}}}
endif "}}}

if Tap('vital.vim') "{{{
  function! VitalWrapper(...) "{{{
    if !exists('g:vital')
      call neobundle#source('vital.vim')
      let g:vital = vital#of('vital')
    endif
    for l:module in a:000
      if !empty(l:module) && !has_key(g:vital, l:module)
        call g:vital.load(l:module)
      endif
    endfor
    return g:vital
  endfunction "}}}
else
  function! VitalWrapper(...) "{{{
    throw 'not exists vital#of'
  endfunction "}}}
endif "}}}

if Tap('VimCalc') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:VCalc_WindowPosition = 'bottom'
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    function! s:vimcalcSetting()
      nnoremap <buffer> q :<C-U>bw<CR>
      nnoremap <buffer> Q :<C-U>bw<CR>
      inoremap <buffer> jj <Esc>j
      inoremap <buffer> kk <Esc>k
    endfunction
  endfunction "}}}
endif "}}}

if Tap('calendar-vim') "{{{
  nmap <Leader>cal <Plug>CalendarV
  nmap <Leader>caL <Plug>CalendarH
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:calendar_focus_today = 1
    let g:calendar_mark = 'left-fit'
    let g:calendar_diary = g:memo_dir . 'diary'
    let g:calendar_datetime = "statusline"
    let g:calendar_filetype = 'markdown'

    let g:calendar_options="fdc=0 nonu"
    if &relativenumber
      let g:calendar_options .= " nornu"
    endif
    if exists("g:calendar_weeknm")
      let g:calendar_options .= " winwidth=27"
    else
      let g:calendar_options .= " winwidth=22"
    endif

    function! s:calendarSetting()
      setl bufhidden=wipe
      setl nobuflisted
      setl nospell
      setl foldcolumn=0
      nnoremap <buffer> q :<C-U>bw<CR>
      nnoremap <buffer> Q :<C-U>bw<CR>
    endfunction

  endfunction "}}}
endif "}}}

if Tap('vim-ref') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    call unite#custom_default_action('ref', 'split')
    let g:ref_use_vimproc = 1
    let g:ref_no_default_key_mappings = 1
    let g:ref_open = 'vsplit'
    let g:ref_use_cache =1
    let g:ref_cache_dir = expand('$VIMFILES/tmp/.vim_ref_cache')
    let g:manual_dir = expand('$HOME/Documents/Manual')
    let g:ref_refe_cmd = g:manual_dir . '/ruby-refm-1.9.3-dynamic-20120829/refe-1_9_3.cmd'
    let g:ref_phpmanual_path = g:manual_dir . '/php-chunked-xhtml'
    function! s:refSetting() "{{{
      setl wrap
      setl nofoldenable
      setl number

      map <buffer> <silent> <CR> <Plug>(ref-keyword)
      map <buffer> <silent> <C-]> <Plug>(ref-keyword)
      map <buffer> <silent> <C-t> <Plug>(ref-back)
      map <buffer> <silent> <C-o> <Plug>(ref-back)
      map <buffer> <silent> <C-i> <Plug>(ref-forward)
      nnoremap <buffer> q :<C-U>bw<CR>
      nnoremap <buffer> Q :<C-U>bw<CR>
    endfunction "}}}
  endfunction "}}}
endif "}}}

if Tap('vim-quickrun') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:quickrun_no_default_key_mappings = 1
    "g:quickrun#default_config
    let g:quickrun_config = {}
    let g:quickrun_config._ = {'runner' : 'vimproc',
      \   'runner/vimproc/updatetime': 500,
      \   'runner/vimproc/sleep': 50,
      \   'runner/vimproc/read_timeout': 10,
      \   'outputter/buffer/running_mark' : '(-_-)zzz',
      \   'outputter/buffer/into' : 0,
      \   'hook/time/enable' : 1,
      \ }

    "'java': {'exec': ['javac %o %s', '%c %s:t:r %a'], 'hook/output_encode/encoding': '&termencoding', 'hook/sweep/files': '%S:p:r.class'},
    let g:quickrun_config.java = {'exec': ['javac %o %S', '%C %S:t:r %a']}
    let g:quickrun_config.checkstyle = {
      \   'exec': printf('java -cp "%s" com.puppycrawl.tools.checkstyle.Main -f plain -c "%s" "%%S" ', g:checkstyle_classpath, g:checkstyle_xml),
      \   'outputter': 'quickfix',
      \   'outputter/quickfix/errorformat': '%f:%l:%v:\ %m,%f:%l:\ %m,%-G%.%#',
      \   'outputter/quickfix/open_cmd': 'doautocmd QuickFixCmdPost quickrun',
      \   'hook/output_encode/encoding' : '&termencoding:&encoding',
      \ }
    "let g:quickrun_config.ruby = {'hook/output_encode/encoding' : '&termencoding'}
    let g:quickrun_config.dosbatch = {
      \   'command': '',
      \   'exec': g:quickrun_config._.runner == 'vimproc' ? '%S:p:gs?/?\\\\\\? %a' : 'call %S:p:gs?/?\\? %a',
      \   'tempfile': '%{tempname()}_quickrun.bat',
      \   'hook/output_encode/encoding' : 'cp932:&encoding',
      \ }
    call extend(g:quickrun_config, {'markdown/pandoc': {
      \   'exec': '%c --from=markdown --to=html5 --standalone %o %s %a',
      \   'outputter': 'browser',
      \   'hook/output_encode/encoding' : 'utf-8:utf-8',
      \   'hook/time/dest' : 'buffer',
      \ }})
    call extend(g:quickrun_config, {'markdown/kramdown': {
      \   'outputter': 'browser',
      \   'hook/output_encode/encoding' : 'utf-8:utf-8',
      \   'hook/time/dest' : 'buffer',
      \ }})

    if executable('pandoc')
      let g:quickrun_config.markdown = {'type': 'markdown/pandoc' }
    elseif executable('kramdown')
      let g:quickrun_config.markdown = {'type': 'markdown/kramdown' }
    endif
    autocmd MyAutoCmd FileType quickrun nnoremap <buffer><expr> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : "\<C-c>"

  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    "{{{ 2012-05-07 - C++でゲームプログラミング
    "http://d.hatena.ne.jp/osyo-manga/20120507
    let g:titlestring_bk = &titlestring
    command! RestoreTitlestring let &titlestring = g:titlestring_bk

    let s:hook = {
      \   "name" : "anime",
      \   "kind" : "hook",
      \   "index_counter" : 0,
      \   "config" : { "enable" : 1 },
      \ }

    function! s:hook.on_ready(session, context)
      let self.index_counter = -2
      let self.titlestring = &titlestring
    endfunction

    function! s:hook.on_output(session, context)
      let self.index_counter += 1
      if self.index_counter < 0
        return
      endif
      let l:aa_list = []
      let l:i = 9
      for n in range(10)
        call add(l:aa_list, repeat('■', n).repeat('□', l:i).' NOW RUNNING')
        let l:i -= 1
      endfor
      let &titlestring = self.titlestring . ' ' .
        \ l:aa_list[ self.index_counter / 5 % len(l:aa_list)  ]
    endfunction
    function! s:hook.on_exit(session, context)
      let &titlestring  = self.titlestring
    endfunction

    call quickrun#module#register(s:hook, 1)
    unlet s:hook
    "}}}
  endfunction "}}}
endif "}}}

if Tap('open-browser.vim') "{{{
  let g:openbrowser_no_default_menus = 1
  nmap gx <Plug>(openbrowser-open)
  vmap gx <Plug>(openbrowser-open)
endif "}}}

if Tap('echodoc') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    " let g:echodoc_enable_at_startup = 1
  endfunction "}}}
  function! neobundle#hooks.on_post_source(bundle) "{{{
    call echodoc#enable()
  endfunction "}}}
endif "}}}

if Tap('gist-vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:gist_show_privates = 1
    let g:gist_detect_filetype = 1
    let g:gist_use_password_in_gitconfig = 1
  endfunction "}}}
endif "}}}

if Tap('vim-ruby') "{{{
  function! neobundle#hooks.on_post_source(bundle) "{{{
    setlocal formatoptions-=r
    setlocal formatoptions-=o
  endfunction "}}}
endif "}}}

"if Tap('css_color.vim') "{{{
"  function! neobundle#hooks.on_post_source(bundle) "{{{
"    let &updatetime = g:update_time
"  endfunction "}}}
"endif "}}}

if Tap('java_fold') "{{{
  function! neobundle#hooks.on_post_source(bundle) "{{{
    autocmd MyAutoCmd Filetype java setlocal foldmethod=expr foldexpr=GetJavaFold(v:lnum) foldtext=JavaFoldText()
  endfunction "}}}
endif "}}}

if Tap('previm') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:previm_show_header=0
    let g:previm_enable_realtime=0
  endfunction "}}}
endif "}}}

if Tap('vim-fontzoom') "{{{
  let g:fontzoom_no_default_key_mappings = 1
  let g:fontzoom_keep_window_size = 0
  nmap [Plug]+ <Plug>(fontzoom-larger)
  nmap [Plug]- <Plug>(fontzoom-smaller)
  nmap [Plug]= <Plug>(fontzoom-smaller)
  nnoremap [Plug]0 :Fontzoom!<CR>
endif "}}}

if Tap('vim-qfreplace') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    function! s:qfreplaceSetting()
    endfunction
  endfunction "}}}
endif "}}}

if Tap('sqlformatter.vim') "{{{
  nmap <Leader>1 <Plug>(Sqlformatter)
  vmap <Leader>1 <Plug>(Sqlformatter)
  function! neobundle#hooks.on_source(bundle) "{{{
    let s:sqlformatter_base = neobundle#is_installed('anbt-sql-formatter') ?
      \ neobundle#get('anbt-sql-formatter').path :
      \ expand('$HOME/bin/anbt-sql-formatter')
    let g:sqlformatter_dir = s:sqlformatter_base.'/lib'

    let g:sqlformatter_cmd = neobundle#is_installed('my-sql-formatter.rb') ?
      \ (neobundle#get('my-sql-formatter.rb').path).'/my-sql-formatter.rb' :
      \ s:sqlformatter_base.'/bin/anbt-sql-formatter'
  endfunction "}}}
endif "}}}

let g:migemodict = expand(printf('$VIMFILES/dict/migemo/%s/migemo-dict', &encoding))
if has('migemo')
  let &migemodict = g:migemodict
endif

if Tap('vim-migemo') "{{{
  function! neobundle#hooks.on_post_source(bundle) "{{{
    call migemo#system('')
  endfunction "}}}
endif "}}}

if Tap('gitignore.vim') "{{{
  function! neobundle#hooks.on_source(bundle) "{{{
    let g:gitignore_dir = expand('$VIMFILES/tmp/.gitignore-boilerplates')
  endfunction "}}}
endif "}}}

if Tap('hz_ja.vim') || exists(':Hankaku') is 2 "{{{
  nnoremap gu :Hankaku<CR>
  nnoremap gh :Hankaku<CR>
  nnoremap gU :Zenkaku<CR>
  nnoremap gz :Zenkaku<CR>
  vnoremap gu :Hankaku<CR>
  vnoremap gh :Hankaku<CR>
  vnoremap gU :Zenkaku<CR>
  vnoremap gz :Zenkaku<CR>
endif "}}}
"}}}

call NeoBundleEnd()

"disabled{{{
let g:loaded_getscriptPlugin = 1
let g:loaded_gzip = 1
let g:loaded_LogiPat = 1
let g:loaded_rrhelper = 1
let g:loaded_tarPlugin= 1
let g:loaded_vimballPlugin = 1
let g:loaded_zipPlugin = 1

let g:loaded_netrwPlugin = 1
let g:loaded_netrw       = 1
"}}}
"kaoriya_disable{{{
if get(g:, 'vimrc_local_finish', 0) != 0
elseif s:has_kaoriya && isdirectory(expand('$VIM/switches/'))
  if has('vim_starting')
    let g:plugin_autodate_disable = 1
    let g:plugin_cmdex_disable = 1
    let g:plugin_dicwin_disable = 1
    " let plugin_hz_ja_disable = 1
    "menu disable PopUp.半角→全角(Z)
    vunmenu PopUp.半角→全角(Z)
    vunmenu PopUp.全角→半角(H)
    vunmenu PopUp.-SEP3-
    vunmenu PopUp
    let g:plugin_scrnmode_disable = 1
    " let plugin_verifyenc_disable = 1
    "let g:loaded_godoc = 1
    let &rtp = join(filter(split(&rtp, ','), 'v:val !~ "^.\\+plugins\\\\golang"'), ',')
  endif
  if exists('g:kaoriya_switch') && exists('path')
    unlet path
  endif
  if exists('*neobundle#is_installed')
    function! s:switchEnabled(name) "{{{
      let l:catalog = expand('$VIM/switches/catalog/') . a:name
      let l:enabled = expand('$VIM/switches/enabled/') . a:name
      if !filereadable(l:enabled) && filereadable(l:catalog)
        let l:V = VitalWrapper('System.File')
        call l:V.System.File.copy(l:catalog, l:enabled)
      endif
    endfunction "}}}
    if neobundle#is_installed('vimdoc-ja')
      call s:switchEnabled('disable-vimdoc-ja.vim')
    endif
    if neobundle#is_installed('vimproc') && !neobundle#config#get('vimproc').local
      call s:switchEnabled('disable-vimproc.vim')
    endif
    call s:switchEnabled('disable-go-extra.vim')
    delfunction s:switchEnabled
  endif

  function! s:writeVimrc_local(name, line) "{{{
    let s:vimrc_local = expand('$VIM/'.a:name)
    if !filereadable(s:vimrc_local)
      let s:ret = writefile(a:line, s:vimrc_local)
      if s:ret is -1
        call EchoError('write fails:' . s:vimrc_local)
      endif
      return s:ret
    endif
  endfunction "}}}
  call s:writeVimrc_local('vimrc_local.vim', ['let g:no_vimrc_example=1'])
  call s:writeVimrc_local('gvimrc_local.vim', ['let g:gvimrc_local_finish=1'])

  delfunction s:writeVimrc_local

endif
"}}}

if has('vim_starting') && s:neobundle_is_installed && s:just_installed_neobundle
  if !neobundle#is_installed('vimproc')
    NeoBundleInstall vimproc
  endif
  if !neobundle#is_installed('unite.vim')
    NeoBundleInstall unite.vim
  endif
  " NeoBundleInstall
  call add(g:messages, 'Please check :NeoBundleLog and execute :NeoBundleInstall or :Unite neobundle/install')
endif

"2html.vim"{{{
let g:html_dynamic_folds = 1
let g:html_no_foldcolumn = 0
let g:html_prevent_copy = "fntd"
"}}}

"}}}
"-----------------------------------------------------------------------------
"ColorScheme Highlight:"{{{

let g:hlightHankakuSpaceLight = 'term=undercurl ctermbg=0 gui=underline guifg=grey70'
let g:hlightZenkakuSpaceLight = 'term=undercurl ctermbg=0 gui=underline guifg=Red guibg=grey90'

let g:hlightHankakuSpaceDark = 'term=undercurl ctermbg=0 gui=underline guifg=grey30'
let g:hlightZenkakuSpaceDark = 'term=undercurl ctermbg=0 gui=underline guifg=Red guibg=grey30'

function! SpaceHighlight() "{{{
  if &background == 'light'
    sil! exe 'hi HankakuSpace '.g:hlightHankakuSpaceLight
    sil! exe 'hi ZenkakuSpace '.g:hlightZenkakuSpaceLight
  else
    sil! exe 'hi HankakuSpace '.g:hlightHankakuSpaceDark
    sil! exe 'hi ZenkakuSpace '.g:hlightZenkakuSpaceDark
  endif
endfunction "}}}

function! SetSpace() abort "{{{
  if !hlexists('ZenkakuSpace')
    call SpaceHighlight()
  endif
  let l:match_not_exists = 1
  for l:matche in getmatches()
    if l:matche.group is 'ZenkakuSpace'
      let l:match_not_exists = 0
      break
    endif
  endfor
  if l:match_not_exists
    call matchadd('HankakuSpace', '\v +\ze[^ \r\n]+', -1)
    call matchadd('ZenkakuSpace', '\v　+', -1)
  endif
endfunction "}}}

"color function"{{{
function! Highlight() "{{{

  highlight Normal ctermfg=15 ctermbg=0

  highlight NonText    gui=none
  highlight LineNr     gui=none
  "  highlight Pmenu      guibg=LightMagenta guifg=black
  highlight Folded     guibg=bg
  highlight CursorIM   guibg=red
  highlight FoldColumn gui=bold
  highlight TabLine     gui=underline guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  highlight TabLineFill gui=underline guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  "highlight TabLineInfo gui=underline guifg=fg guibg=NONE
  highlight TabLineInfo gui=underline,bold guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  "highlight TabLineNo gui=underline,bold guifg=Black guibg=lightgray ctermfg=fg ctermbg=bg
  highlight TabLineNo gui=underline,bold guifg=white guibg=DarkGreen ctermfg=15 ctermbg=2
  highlight TabLineSep  gui=underline guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  "highlight TabLineSel  gui=underline,reverse,bold guifg=Black guibg=grey80
  highlight TabLineSel  gui=underline,reverse guifg=fg guibg=NONE ctermfg=0 ctermbg=15
  "highlight link TabLineMod Error
  highlight TabLineMod gui=underline guifg=fg guibg=Red ctermfg=fg ctermbg=12

  highlight StatusLineBufNum gui=bold guibg=bg
  highlight StatusLineMsg gui=bold guifg=red guibg=NONE
  highlight StatusLineModeMsg   term=bold ctermfg=14 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgNO term=bold ctermfg=14 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgIN term=bold ctermfg=14 gui=bold,reverse guifg=red
  highlight StatusLineModeMsgCL term=bold ctermfg=14 gui=bold,reverse guifg=red
  highlight StatusLineModeMsgRE term=bold ctermfg=14 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgRV term=bold ctermfg=14 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgVI term=bold ctermfg=14 gui=bold,reverse guifg=lightblue
  highlight StatusLineModeMsgVL term=bold ctermfg=14 gui=bold,reverse guifg=LightSkyBlue
  highlight StatusLineModeMsgVB term=bold ctermfg=14 gui=bold,reverse guifg=DodgerBlue
  highlight StatusLineModeMsgSE term=bold ctermfg=14 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgSB term=bold ctermfg=14 gui=bold,reverse guifg=green
endfunction "}}}
function! s:morning() "{{{
  highlight StatusLine   guifg=RoyalBlue
  highlight StatusLineNC gui=reverse,bold
  highlight SpecialKey   guifg=DarkGreen  guibg=grey90
  highlight Pmenu        guibg=LightMagenta guifg=black
  highlight Normal       guifg=Black      guibg=grey100
endfunction "}}}
function! s:desert() "{{{
  highlight Normal  ctermfg=15 ctermbg=0  guibg=grey10
  " highlight NonText term=bold  ctermfg=15 ctermbg=0 guifg=cyan guibg=gray17
  highlight NonText term=bold  ctermfg=15 ctermbg=0 guifg=cyan guibg=#000000
  highlight Cursor  guibg=#ffff99
  highlight clear  Visual
  highlight Visual gui=none guibg=grey30 ctermbg=8
  highlight LineNr guifg=lightred guibg=black
  highlight Pmenu      ctermfg=15 ctermbg=8 guifg=#000000 guibg=#a6a190
  highlight PmenuSel   ctermfg=15 ctermbg=9 guifg=#ffffff guibg=#133293
  highlight PmenuSbar  ctermfg=0  ctermbg=0 guibg=#555555
  highlight PmenuThumb ctermfg=7  ctermbg=7 guibg=#cccccc
  highlight WildMenu   guifg=#ffffff    guibg=#133293
  highlight Folded guifg=#c2bfa5
  highlight CursorLine term=underline guibg=#2b3b20
  " highlight Statement  gui=bold guifg=khaki
  " highlight Type term=underline ctermfg=2 gui=bold guifg=darkkhaki
  highlight Type guifg=#5f7f3f
  highlight StatusLineNC guibg=grey30
endfunction "}}}
"}}}

augroup MyColor "{{{
  autocmd!
  autocmd ColorScheme * silent call SpaceHighlight()
  autocmd VimEnter,WinEnter,CmdwinEnter,ColorScheme * silent call SetSpace()
  autocmd ColorScheme * silent call Highlight()
    \|if exists('g:colors_name') && exists("*s:".substitute(g:colors_name, '-', '', 'g'))
    \| silent call s:{substitute(g:colors_name, '-', '', 'g')}()
    \|endif
  if g:is_view
    autocmd VimEnter * colorscheme desert
    autocmd VimEnter * silent doautocmd ColorScheme
  else
    autocmd VimEnter * silent call s:colorscheme_restore()
    autocmd VimLeavePre * let g:MY_COLORSCHEME = get(g:, 'colors_name', '')
  endif
augroup END "}}}

function! s:colorscheme_restore() "{{{
  let l:colorname = get(g:, 'MY_COLORSCHEME', 'desert')

  " 存在チェックを行う場合は以下を有効化
  "if len(filter(split(globpath(&runtimepath, 'colors/*.vim'), '\n'), 'v:val =~ l:colorname')) is 0
    "let l:msg = l:colorname."doesn't exist"
    "let l:colorname = 'evening'
  "endif
  try
    silent exe 'colorscheme ' . l:colorname
  catch /^Vim\%((\a\+)\)\=:E185/
    silent exe 'colorscheme desert'
  endtry
  silent doautocmd ColorScheme
endfunction "}}}

" colorsel.vim
" https://gist.github.com/mattn/28009873b42dd2c1d62a
function! s:colorScheme_select() "{{{
  let l:V = VitalWrapper('Vim.BufferManager')
  let l:buf = l:V.Vim.BufferManager.new()
  call l:buf.open('colorScheme_select', {'opener': '20vsplit'})

  setl modifiable
  let l:colors = map(split(globpath(&runtimepath, 'colors/*.vim'), '\n'), 'fnamemodify(v:val, ":t:r")')
  call setline(1, l:colors)
  setl buftype=nofile
  setl bufhidden=wipe
  setl nobuflisted
  setl nomodifiable
  setl readonly
  setl number
  setl nowrap
  setl cursorline
  setl nospell
  setl foldcolumn=0
  let b:lastLnum = len(l:colors)

  nnoremap <buffer> <silent> <CR> :<c-u>exe 'color' getline('.')<cr>
  nnoremap <buffer> <silent> <Space> :<c-u>exe 'color' getline('.')<cr>
  nnoremap <buffer> <silent> q :<C-U>bw<CR>
  nnoremap <buffer> <silent> Q :<C-U>bw<CR>
  nnoremap <buffer> <silent> <expr> j (line('.') is b:lastLnum ? 'gg' : 'j')
  nnoremap <buffer> <silent> <expr> k (line('.') is 1 ? 'G' : 'k')

endfunction "}}}
command! SelectColorScheme call s:colorScheme_select()
nnoremap <F9> :<C-u>SelectColorScheme<CR>

syntax enable

"}}}
"-----------------------------------------------------------------------------
"FileType Settings:{{{
filetype plugin indent on

set formatoptions-=r
set formatoptions-=o
" 行連結に関する設定
set formatoptions+=mBj
" コメント自動折返し時、コメント文字列自動挿入
set formatoptions+=c
" gqでコメント整形
set formatoptions+=q
" filetype detect "{{{
augroup MyAutoCmd
  autocmd BufRead,BufNewFile .vrapperrc setlocal filetype=vim
  autocmd BufRead,BufNewFile *.{md,mkd} setlocal filetype=markdown
  autocmd BufRead,BufNewFile *.js setlocal filetype=javascript syntax=jquery
  autocmd BufRead,BufNewFile *.wlst setlocal filetype=python
  " autocmd BufRead,BufNewFile *.log setlocal filetype=messages
  "Pro cobol
  autocmd BufRead,BufNewFile *.pco setlocal filetype=cobol
  "autocmd BufRead,BufNewFile *.erb set filetype=eruby.html
  "xxd"{{{
  "Vim-users.jp - Hack #133: バイナリファイルを編集する
  "http://vim-users.jp/2010/03/hack133/
  "特定の拡張子をバイナリ編集で開始
  "autocmd BufReadPost,BufNewFile *.bin,*.exe,*.dll setlocal filetype=xxd
  "}}}
  autocmd BufEnter * if empty(&filetype) | filetype detect | endif
augroup END
"}}}

augroup MyAutoCmd "{{{
  autocmd FileType * setlocal formatoptions-=r
    \| setlocal formatoptions-=o
    \| setlocal formatoptions+=mBj
  autocmd FileType html,xhtml,javascript,css
    \  setlocal autoindent
    \| setlocal smartindent
  autocmd FileType * if exists("*s:".substitute(&filetype, '-', '', 'g').'Setting')
    \|  call s:{substitute(&filetype, '-', '', 'g')}Setting()
    \|endif

  "help{{{
  function! s:helpSetting()
    setlocal colorcolumn&
    setlocal noswapfile
    nnoremap <buffer> q :<C-U>bw<CR>
    nnoremap <buffer> Q :<C-U>bw<CR>
    nnoremap <buffer> g<C-]> <C-]>
    nnoremap <buffer> <C-]> g<C-]>
  endfunction
  "}}}
  "vim"{{{
  "埋込言語のsyntax
  let g:vimsyn_embed = 'Ppr'
  let g:vimsyn_folding = 0
  "接続行のインデント数
  let g:vim_indent_cont = &sw * 1
  function! s:vimSetting() "{{{
    setlocal expandtab
    call IndentSet(2)
    let g:vim_indent_cont = &sw * 1
    setlocal autoindent
    setlocal smartindent
    setlocal foldmethod=marker
    setlocal formatoptions-=r
    setlocal formatoptions-=o
    nnoremap <buffer> <C-F2> :<C-u>Set<CR>
    nnoremap <buffer> <C-F3> :<C-u>SetH<CR>
  endfunction "}}}
  "}}}
  "cobol{{{
  function! s:cobolSetting() "{{{
    setlocal expandtab
    call IndentSet(4)
    setlocal autoindent
    setlocal smartindent
    setlocal dictionary+=$VIMDICT/COBOL.dict
    setlocal cc=+1
    highlight ColorColumn guibg=grey30
    "syntax
    syn clear cobolBadLine
    syn match cobolBadLine "[^ D\*$/-].*" contained
    syn match cobolBadLine "\s\+\*.*" contained
    if exists("cobol_legacy_code")
      syn match cobolBadLine "\%73v.*" containedin=ALLBUT,cobolComment
    else
      syn match cobolBadLine "\%73v.*" containedin=ALL
    endif
    "mapping
    nnoremap <buffer> [COBOL] <Nop>
    inoremap <buffer> [COBOL] <Nop>
    vnoremap <buffer> [COBOL] <Nop>
    nmap <buffer> <C-Return> [COBOL]
    imap <buffer> <C-Return> [COBOL]
    vmap <buffer> <C-Return> [COBOL]
    nmap <silent> <buffer> [COBOL]t  <Plug>Traditional
    nmap <silent> <buffer> [COBOL]cd  <Plug>Comment
    nmap <silent> <buffer> [COBOL]cc  <Plug>DeComment
    vmap <silent> <buffer> [COBOL]t <Plug>VisualTraditional
    vmap <silent> <buffer> [COBOL]cd  <Plug>VisualComment
    vmap <silent> <buffer> [COBOL]cc  <Plug>VisualDeComment
    nnoremap <silent> [COBOL]? :Mapping [COBOL]<CR>
  endfunction "}}}
  "}}}
  "Ruby"{{{
  "let ruby_no_expensive = 1 "endに対するブロック開始分にしたがった色付けを無効
  let ruby_operators = 1 "演算子ハイライト
  let ruby_space_errors = 1 "ホワイトスペースエラー
  let ruby_fold = 1
  let ruby_no_comment_fold = 1
  function! s:rubySetting() "{{{
    setlocal expandtab
    call IndentSet(2)
    setlocal autoindent
    setlocal smartindent
    setlocal dictionary+=$VIMDICT/ruby.dict
    setlocal foldlevelstart=99
  endfunction "}}}
  function! s:erubySetting() "{{{
    call s:rubySetting()
  endfunction "}}}
  "}}}
  "sql{{{
  function! s:sqlSetting() "{{{
    setlocal expandtab
    call IndentSet(2)
    setlocal autoindent
    setlocal smartindent
    setlocal dictionary+=$VIMDICT/sql.dict
    "syntax
    syntax case ignore
    syn keyword sqlKeyword case
    syn keyword sqlKeyword left right inner outer join
    syn keyword sqlKeyword count
    syn keyword sqlKeyword isnull
    syn keyword sqlKeyword partition
    syn keyword sqlKeyword row_number to_date decode
    syn keyword sqlType nchar nvarchar nvarchar2 timestamp
    syn keyword sqlOperator over
    syn match sqlSpecial "@\w*"
  endfunction "}}}
  "}}}
  "dosbatch"{{{
  autocmd FileType dos setlocal filetype=dosbatch
  autocmd BufNewFile * if &l:filetype ==? 'dosbatch' | setlocal fileformat=dos fileencoding=cp932 | endif
  function! s:dosbatchSetting() "{{{
    let g:dosbatch_cmdextversion = 1
    let b:match_words = '\<SETLOCAL\>:\<ENDLOCAL\>'
    "let b:match_words .= ',%:%'

    setlocal matchpairs+=%:%
    setlocal dictionary+=$VIMDICT/dosbatch.dict

    syn match dosbatchLineComment '^\s*REM.*$'
    syn match dosbatchLineComment '^\s*@REM.*$'
    hi def link dosbatchLineComment Comment

  endfunction "}}}
  "}}}
  "java"{{{
  let g:java_highlight_all=1
  let g:java_highlight_debug=1
  let g:java_space_errors=1
  let g:java_highlight_java_lang_ids=1
  let g:java_highlight_functions="style"
  "let java_highlight_functions="indent"
  let g:java_minlines = 30
  function! s:JavaSetting()
    setl textwidth=150
    "setl foldmethod=syntax
    "fold-expr
    "setl foldmethod=marker
    "setl foldmarker={,}
    "setl foldmethod=expr
    "setl foldexpr=getline(v:lnum)=~'^\\s*$'&&getline(v:lnum+1)=~'\\S'?'<1':1
  endfunction
  "}}}
  "autohotkey"{{{
  function! s:autohotkeySetting()
    call IndentSet(2)
    setl textwidth=78
    setl autoindent
    setl smartindent
    setl expandtab
    setl dictionary+=$VIMDICT/ahk.dict
  endfunction
  "}}}
  "qf{{{
  function! s:qfSetting() "{{{
    setlocal colorcolumn&
    setlocal cursorline
    nnoremap <buffer> q :<C-U>bw<CR>
    nnoremap <buffer> Q :<C-U>bw<CR>

    if exists(':Qfreplace') is 2
      nnoremap <buffer> r :<C-u>Qfreplace<CR>
    endif
  endfunction "}}}
  "}}}
  "html,jsp{{{
  function! s:htmlSetting() "{{{
    call IndentSet(2)
    let &updatetime = g:update_time
  endfunction "}}}
  function! s:jspSetting() "{{{
    call s:htmlSetting()
  endfunction "}}}
  function! s:xhtmlSetting() "{{{
    call s:htmlSetting()
  endfunction "}}}
  "}}}
  "xml{{{
  function! s:xmlSetting() "{{{
    compiler xmllint
    let &l:makeprg=&makeprg. ' %:p'
    call IndentSet(2)
    let g:xml_syntax_folding = 1
    setl foldmethod=syntax
  endfunction "}}}
  "}}}
  "markdown{{{
  function! s:markdownSetting() "{{{
    setlocal formatoptions+=w
    call IndentSet(2)
  endfunction "}}}
  "}}}
  "yaml{{{
  function! s:yamlSetting() "{{{
    call IndentSet(2)
  endfunction "}}}
  "}}}

  "complete-functions
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  "autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  "autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS

  "dictionary
  autocmd FileType css setlocal dictionary+=$VIMDICT/css.dict
  autocmd FileType html,xhtml,javascript,jquery setlocal dictionary+=$VIMDICT/html.dict dictionary+=$VIMDICT/javascript.dict dictionary+=$VIMDICT/jquery.dict

augroup END "}}}

function! IndentSet(...) "{{{
  if empty(a:000)
    execute 'setlocal tabstop?'
    execute 'setlocal shiftwidth?'
    execute 'setlocal softtabstop?'
    return
  endif
  if type(a:1) != type(0)
    call EchoError('Argument must be Number : args '.a:1)
    return
  endif
  if a:1 < 1
    call EchoError('Argument must be positive : args '.a:1)
    return
  endif
  execute 'setlocal tabstop='.a:1
  execute 'setlocal shiftwidth='.a:1
  execute 'setlocal softtabstop='.a:1
endfunction "}}}
command! -nargs=? IndentSet call IndentSet(<args>)

augroup javap
  autocmd!
  autocmd BufReadPre,FileReadPre *.class setlocal binary
  autocmd BufReadPost,FileReadPost *.class call JavapCurrentBuffer()
augroup END

function! JavapCurrentBuffer() "{{{
  silent execute '%del _'

  let l:V = VitalWrapper('Prelude', 'System.Filepath')
  let l:abs = l:V.System.Filepath.abspath(expand('%'))
  if l:V.Prelude.is_windows()
    let l:path = l:V.System.Filepath.winpath(l:abs)
  else
    let l:path = l:V.System.Filepath.realpath(l:abs)
  endif
  if executable('jad')
    let l:result = System(printf('jad -8 -p "%s"', l:path))
  else
    let l:result = System(printf('javap -c -v -p -s "%s"', l:path))
  endif
  execute '0put =l:result'
  normal! gg
  setlocal filetype=java
  setlocal readonly
  setlocal nomodifiable
  setlocal nobinary
endfunction "}}}

if g:is_windows
  augroup office_readonly
    autocmd!
    let s:pattern = ':p:gs?/?\?:gs?\\?\\\\?'
    exe printf("autocmd BufReadPre %s echo CmdStart(g:office_readonly_path . "
      \."' ' . fnamemodify(expand('<afile>'), '%s'))"
      \, g:office_readonly_extensions, s:pattern)
    exe printf("autocmd BufRead %s bw", g:office_readonly_extensions)
    unlet s:pattern
  augroup END
endif

"}}}
"-----------------------------------------------------------------------------
"Commands Functions:"{{{

"tabopen{{{
command! -nargs=* -complete=file E tabnew <args>
command! -nargs=* -complete=file Enew tabnew <args>
command! -nargs=? -complete=help TH tab help <args>
command! -nargs=? -complete=help THelp tab help <args>
"}}}
"vertical open{{{
command! -nargs=? -complete=help H vertical help <args>
command! -nargs=? -complete=help Help vertical help <args>
command! -nargs=? -complete=help VHelp vertical help <args>
command! -nargs=? -complete=help VH vertical help <args>
"}}}

function! s:createEncCommand(fencs)  "{{{
  for l:enc in a:fencs
    let l:base = 'command! -bang -nargs=? -complete=file %s %s<bang> ++enc=%s <args>'
    let l:name = substitute(substitute(l:enc, '\w\+', '\L\u&', 'g'), '-', '', 'g')
    execute printf(l:base, l:name, 'edit', l:enc)
    execute printf(l:base, 'Tab'.l:name, 'tabedit', l:enc)
  endfor
endfunction "}}}
call s:createEncCommand(s:fencs)


"Edit VIMRC:{{{
"let s:cmd = has('gui_running') ? 'drop' : 'split'
"command! MYVIMRC exe printf("tab %s $MYVIMRC", s:cmd)
"command! MYGVIMRC exe printf("tab %s $MYGVIMRC", s:cmd)
command! MYVIMRC  tab split $MYVIMRC
command! MYGVIMRC tab split $MYGVIMRC
noremap <Leader>vim  :<C-u>MYVIMRC<CR>
noremap <Leader>gvim :<C-u>MYGVIMRC<CR>
noremap <Leader>VIM  :<C-u>vsplit $MYVIMRC<CR>
"}}}

"Trim:"{{{
function! s:LTrimFunc(first,last,bang) "{{{
  let l:pattern = 's/^[ \t'.(a:bang == '!' ? '　' : '').']\+//g'
  silent! execute a:first.','a:last.l:pattern
endfunction "}}}
function! s:RTrimFunc(first,last,bang) "{{{
  let l:pattern = 's/[ \t'.(a:bang == '!' ? '　' : '').']\+$//g'
  silent! execute a:first.','a:last.l:pattern
endfunction "}}}
function! s:TrimFunc(first,last,bang) "{{{
  call s:LTrimFunc(a:first,a:last,a:bang)
  call s:RTrimFunc(a:first,a:last,a:bang)
endfunction "}}}
command! -range=% -bang  Trim call s:TrimFunc(<line1>, <line2>, '<bang>')
command! -range=% -bang LTrim call s:LTrimFunc(<line1>, <line2>, '<bang>')
command! -range=% -bang RTrim call s:RTrimFunc(<line1>, <line2>, '<bang>')
nnoremap <M-l> :<C-u>LTrim<CR>
nnoremap <M-r> :<C-u>RTrim<CR>
vnoremap <M-l> :LTrim<CR>gv
vnoremap <M-r> :RTrim<CR>gv
"}}}

"CopyXX:"{{{
command! CopyFileName exe "let @*=expand('%:t')"
command! CopyFileDir exe "let @*=expand('%:p:h')"
command! CopyFilePath exe "let @*=expand('%:p')"
command! CopyFilePathFowWin exe "let @*=expand('%:p:gs?/?\\?')"
command! ConvertWinPath exe "let @*=tr(@*, '/', '\\')"
"command! -range Lcopy execute "<line1>,<line2>copy ".(line(".") - 1)
"nnoremap gy :Lcopy<CR>
"vnoremap gy :Lcopy<CR>
"}}}

"Grep:{{{
function! s:Grep(cmd, ...) abort "{{{
  let l:cmd = a:cmd
  let l:pattern = get(a:000, 0, '')
  let l:target = get(a:000, 1, '')

  call inputsave()
  if empty(l:pattern)
    let l:pattern = input('pattern : ' )
  endif
  if empty(l:target)
    let l:target = input('target : ', expand('%'.(g:is_windows ? ':p' : '')))
  endif
  call inputrestore()

  if !empty(l:cmd) && !empty(l:pattern) && !empty(l:target)
    let l:cmd = printf(l:cmd, l:pattern, l:target)
    let l:fname = matchstr(l:cmd, '\v^\w+')
    execute printf('noautocmd %s |doautocmd QuickFixCmdPost %s', l:cmd, l:fname)
  endif
endfunction "}}}
command! -nargs=* -complete=file VimGrep
  \ call s:Grep('vimgrep /%s/gj %s', <f-args>)
command! -nargs=* -complete=file LVimGrep
  \ call s:Grep('lvimgrep /%s/gj %s', <f-args>)
command! -nargs=* -complete=file Grep call s:Grep('grep! %s %s', <f-args>)
command! -nargs=* -complete=file LGrep call s:Grep('lgrep! %s %s', <f-args>)

function! s:UGrepFunc() "{{{
  exe 'Unite -buffer-name=grep -no-quit -default-action=tabopen grep'
endfunction "}}}
command! UGrep call s:UGrepFunc()
"}}}

"Toggle:{{{
function! s:ToggleOption(option, bang) "{{{
  if empty(&buftype) || a:bang == '!'
    exe 'setl ' a:option.'!'
    exe 'setl ' a:option.'?'
  else
    call EchoWarning(printf('buftype is [%s]. cannot toggle %s.', &buftype, a:option))
  endif
endfunction "}}}
command! -bang ToggleModifiable call s:ToggleOption('modifiable', '<bang>')
command! -bang ToggleReadOnly   call s:ToggleOption('readonly',   '<bang>')
command! -bang ToggleExpandTab  call s:ToggleOption('expandtab',  '<bang>')
command! -bang ToggleImDisable  call s:ToggleOption('imdisable',  '<bang>')
command! -bang ToggleSwapfile   call s:ToggleOption('swapfile',  '<bang>')
nnoremap <Leader>R :ToggleModifiable<CR>
nnoremap <Leader>S :ToggleSwapfile<CR>
"}}}

"Session"{{{
let g:sessionBaseDir = $VIMFILES.'/tmp/session/'
let g:sessionDefaultName = 'session.vim'
function! SessionMake() "{{{
  call inputsave()
  let l:sessinFileName = input('Please input session file name : ', g:sessionDefaultName)
  if !empty(l:sessinFileName)
    execute 'mksession! '.g:sessionBaseDir.l:sessinFileName
  endif
  call inputrestore()
endfunction "}}}
function! SessionSelect() "{{{
  let l:sessionDir = g:sessionBaseDir
  let l:lines = map(expand(g:sessionBaseDir.'*', 1, 1), 'fnamemodify(v:val, ":t")."    |".fnamemodify(v:val, ":p")')
  call MakeBuf('SessionSelect')
  setl modifiable
  setl noreadonly
  silent %d _
  call setline(1, l:lines)
  setl buftype=nofile
  setl bufhidden=wipe
  setl nobuflisted
  setl nomodifiable
  setl readonly
  setl number
  setl nowrap
  setl cursorline
  setl nospell
  setl foldcolumn=0
  let b:lastLnum = len(l:lines)
  vert resize 20
  let b:sessionFunc = {}
  function! b:sessionFunc.execute() "{{{
    let l:bufnr = bufnr('%')
    let l:path = split(getline("."), '|', 1)[1]
    exe tabpagenr('$').'tabnew'
    exe 'source '.l:path
    exe 'bw! SessionSelect'
    exe 'tablast'
  endfunction "}}}
  function! b:sessionFunc.delete() "{{{
    let l:bufnr = bufnr('%')
    let l:path = split(getline("."), '|', 1)[1]
    call inputsave()
    let l:sessinFileName = input(l:path."\nAre you sure you want to remove file ? [y/n] : ")
    call inputrestore()
    let l:result = 0
    if l:sessinFileName == 'y'
      let l:result = delete(l:path)
      if l:result != 0
        call EchoError('delete fails : ' . l:path)
      endif
    endif
  endfunction "}}}

  nnoremap <buffer> <silent> <CR> :<C-u>call b:sessionFunc.execute()<CR>
  nnoremap <buffer> <silent> D :<C-u>call b:sessionFunc.delete()<CR>:call SessionSelect()<CR>
  nnoremap <buffer> <silent> p :<c-u>exe 'pedit ' matchstr(getline("."), "\|.*$")[1:]<cr>
  nnoremap <buffer> <silent> q :<C-U>bw<CR>
  nnoremap <buffer> <silent> Q :<C-U>bw<CR>
  nnoremap <buffer> <silent> <C-r> :<C-u>call SessionSelect()<CR>
  nnoremap <buffer> <silent> <expr> j (line('.') is b:lastLnum ? 'gg' : 'j')
  nnoremap <buffer> <silent> <expr> k (line('.') is 1 ? 'G' : 'k')

endfunction "}}}
function! s:Session(bang, session) "{{{
  let l:session = empty(a:session) ? g:sessionBaseDir . g:sessionDefaultName : a:session
  let l:session = expand(l:session)
  try
    if a:bang == '!'
      if filereadable(l:session)
        execute 'source '.l:session
      else
        call EchoWarning(printf('file not readable [%s]', l:session))
      endif
    else
      execute 'mksession! '.l:session
    endif
  catch
    call EchoWarning(v:throwpoint . "\n" . v:exception)
  endtry
endfunction "}}}
command! -nargs=? SessionMake call s:Session('', <q-args>)
command! -nargs=? SessionLoad call s:Session('!', <q-args>)
"nnoremap <Leader>sm :<C-u>SessionMake<CR>
"nnoremap <Leader>sl :<C-u>SessionLoad<CR>
nnoremap <Leader>sm :<C-u>call SessionMake()<CR>
nnoremap <Leader>sl :<C-u>call SessionSelect()<CR>

"RestoreSession "{{{
if !g:is_view || v:servername !=? 'SUDO' || v:servername !=? 'SUDOW'
  let g:restore_vim_path = expand('$VIMFILES/tmp/restore.vim')
  function! SessionSave() abort "{{{
    if v:dying is 0 && len(filter(range(1, bufnr('$')), 'bufexists(v:val) && bufname(v:val) !=# ""')) is 0
      exe 'SessionClear'
    else
      exe 'SessionMake ' . g:restore_vim_path
    endif
  endfunction "}}}
  augroup RestoreSession "{{{
    autocmd!
    autocmd VimLeave * call SessionSave()
    autocmd VimEnter * if filereadable(g:restore_vim_path) | execute 'SessionLoad ' . g:restore_vim_path | endif
  augroup END "}}}
  command! SessionClear call delete(g:restore_vim_path)|autocmd! RestoreSession VimLeave
endif
"}}}

"}}}

"xmllint-format"{{{
if executable('xmllint')

  function! s:XmlLineFormat(first,last) "{{{
    let l:cmd = 'xmllint --format --recover -'
    let l:input = join(getline(a:first, a:last), "\n")
    let l:result = system(l:cmd, l:input)
    silent execute a:first . ',' . a:last . 'del _'
    execute string(a:first - 1) . 'put =l:result'
    redraw
    echo 'xmllint format finish'
  endfunction "}}}
  command! -range=% XmlLineFormat call s:XmlLineFormat(<line1>, <line2>)

  function! s:XmlFileFormat(filePath) "{{{
    let l:filePath = fnamemodify(expand(a:filePath), g:rep_path)
    if g:is_windows
      let l:filePath = fnamemodify(l:filePath, ':gs?\\?\\\\?')
    endif
    if !filereadable(l:filePath)
      redraw
      echo printf('file not readable [%s]', l:filePath)
      return
    endif
    let l:cmd = printf('xmllint --format --recover "%s"', l:filePath)
    let l:result = system(l:cmd)
    silent execute '%del _'
    execute '0put =l:result'
    redraw
    echo 'xmllint format finish'
  endfunction "}}}
  command! -nargs=1 -complete=file XmlFileFormat call s:XmlFileFormat(<q-args>)

endif
"}}}

"Nkf:"{{{
if executable('nkf')
  " 入力をシステム文字コードに変換する"{{{
  function! IconvSystem(input)
    if g:is_windows
      let l:system = 'windows'
    elseif g:is_mac
      let l:system = 'mac'
    else
      let l:system = 'unix'
    endif
    let l:V = VitalWrapper('Process')
    return l:V.Process.system('nkf --'.l:system, a:input)
  endfunction
  "}}}
  command! Nkf echo system(printf('nkf -g "%s"', expand("%:p")))
  command! Nkfwin execute printf('!start nkfwin -g "%s"', IconvSystem(expand("%:p")))
endif
"}}}

"Vim-users.jp - Hack #203: 定義されているマッピングを調べる"{{{
"http://vim-users.jp/2011/02/hack203/
command! -nargs=* -complete=mapping AllMaps map <args> | map! <args>
"}}}

" E517
function! s:AllBwipeout() "{{{
  let l:list = []
  for l:i in range(1, bufnr('$'))
    if bufexists(l:i)
      call add(l:list, l:i)
    endif
  endfor
  execute 'confirm bwipeout ' . join(l:list)
endfunction "}}}
command! -bang AllBwipeout call s:AllBwipeout()
nnoremap <silent> <Leader>ab :AllBwipeout<CR>

"ウインドウを閉じずにバッファを閉じる - 物置き{{{
"http://d.hatena.ne.jp/ampmmn/20090116/1232115610
function! s:BufCloseIt(cmd, bang) "{{{
  let l:currentBufNum = bufnr("%")
  let l:alternateBufNum = bufnr("#")

  if buflisted(l:alternateBufNum) && (a:bang == '!' || &mod == 0)
    silent buffer #
  else
    silent bnext
  endif

  if bufnr("%") == l:currentBufNum
    " bangが空でバッファが変更されている場合bwipeoutは失敗するのでnewは不要
    if a:bang == '!' || &mod==0
      silent new
    endif
  endif

  if buflisted(l:currentBufNum)
    try
      execute "silent ".a:cmd.a:bang." ".l:currentBufNum
    catch /^Vim\%((\a\+)\)\=:E89/
      " bwipeoutに失敗した場合はウインドウ上のバッファを復元
      if bufloaded(l:currentBufNum)
        silent execute "buffer " . l:currentBufNum
      endif
      redraw
      call EchoWarning(v:exception)
    endtry
  endif
endfunction "}}}
command! -bang Bd call s:BufCloseIt('bd', '<bang>')
command! -bang Bw call s:BufCloseIt('bw', '<bang>')
nnoremap <Leader>wi :Bw<CR>
nnoremap <Leader>wI :Bw!<CR>
"}}}

"AutoLCD"{{{
function! s:LCD() "{{{
  if !empty(bufname('%')) && empty(&buftype)
    let l:head = expand("%:p:h")
    execute ':lcd ' . (isdirectory(l:head) ? l:head : '')
  endif
endfunction "}}}
function! AutoLCD() "{{{
  let g:autoLCD = !get(g:, 'autoLCD', 0)
  autocmd! AutoLCD
  if g:autoLCD
    autocmd AutoLCD BufRead * if get(g:, 'autoLCD', 0) | call s:LCD() | endif
    return 'AutoLCD enable'
  else
    return 'AutoLCD disable'
  endif
endfunction "}}}
command! AutoLCD echo AutoLCD()
"}}}

"from kaoriya
command! -nargs=0 CdCurrent lcd %:p:h|let w:pwd = getcwd()
nnoremap gc :<C-u>CdCurrent<CR>

function! s:CdProjectDirectory() "{{{
  let l:V = VitalWrapper('Prelude')
  let l:dir = l:V.Prelude.path2project_directory(expand('%:p'), 1)
  if !empty(l:dir)
    execute 'lcd ' .l:dir
    echo l:dir
  endif
endfunction "}}}
command! -nargs=0 CdProjectDirectory call s:CdProjectDirectory()

"SynCheck"{{{
function! s:SynCheck() "{{{
  for id in synstack(line("."), col("."))
    exe 'verbose hi '.synIDattr(id, "name")
    exe 'verbose hi '.synIDattr(synIDtrans(id), "name")
  endfor
endfunction "}}}
command! SynCheck call s:SynCheck()
"}}}

function! s:Redir(bang, cmd) "{{{
  let l:V = VitalWrapper('Vim.Message')
  let l:Redir = l:V.Vim.Message.capture(a:cmd)
  if a:bang != '!'
    execute 'tabnew'
  endif
  execute ''.(a:bang != '!' ? '0' : '').'put =l:Redir'
endfunction "}}}
command! -bang -nargs=+ -complete=command Redir call s:Redir('<bang>',<q-args>)

"Vim-users.jp - Hack #84: バッファの表示設定を保存する"{{{
"http://vim-users.jp/2009/10/hack84/
function! s:View(bang) "{{{
  try
    if !empty(expand('%')) && empty(&buftype)
      if a:bang == '!'
        execute 'silent loadview'
      else
        execute 'mkview!'
      endif
    endif
  catch /^Vim\%((\a\+)\)\=:E190/
  catch
    redraw
    echomsg v:throwpoint
    echomsg v:exception
  endtry
endfunction "}}}
nnoremap <Leader>vm :<C-u>call <SID>View('')<CR>
nnoremap <Leader>vl :<C-u>call <SID>View('!')<CR>
autocmd MyAutoCmd BufWritePost,BufUnload * call s:View('')
autocmd MyAutoCmd BufRead * call s:View('!')

"}}}

function! System(expr) "{{{
  if HasVersion('7.4.122')
    return Incoming(system(a:expr))
  else
    return Incoming(system(Outgoing(a:expr)))
  endif
endfunction "}}}
function! Start(cmd) "{{{
  silent exe '!start ' . Outgoing(a:cmd)
endfunction "}}}
function! CmdStart(...) "{{{
  if exists(':VimProcBang') is 2
    return vimproc#system('cmd /C start "" '.join(a:000, ' '))
  else
    return System('cmd /C start "" '.join(a:000, ' '))
  endif
endfunction "}}}
function! Open(...) "{{{
  let l:V = VitalWrapper('System.File')
  return l:V.System.File.open(join(a:000, ' '))
endfunction "}}}
"conversion"{{{
function! Outgoing(cmd)
  return s:iconv(a:cmd, &encoding, 'char')
endfunction
function! Incoming(cmd)
  return s:iconv(a:cmd, 'char', &encoding)
endfunction
function! s:iconv(expr, from, to)
  let l:V = VitalWrapper('Process')
  return l:V.Process.iconv(a:expr, a:from, a:to)
endfunction
"}}}

command! -nargs=? -complete=option Set execute 'verb setl '.(len('<args>') ? '<args>' : expand('<cword>')).'?'
command! -nargs=? -complete=option SetH execute "H '".(len('<args>') ? '<args>' : expand('<cword>'))
command! FTdetect filetype detect
command! FMMarker setl foldmethod=marker

"Vim の :message 履歴をクリアする - C++でゲームプログラミング
"http://d.hatena.ne.jp/osyo-manga/20130502/1367499610
command! MessagesClear for n in range(200) | echom '' | endfor | unlet n

function! s:RegistersClear() "{{{
  for num in range(10)
    exe 'let l:temp = @'.num
    if !empty(l:temp)
      exe 'let @'.num.'=""'
    endif
  endfor
  for char in range(char2nr('a'), char2nr('z'))
    exe 'let l:temp = @'.nr2char(char)
    if !empty(l:temp)
      exe 'let @'.nr2char(char).'=""'
    endif
  endfor
  let @"=""
  let @-=""
  let @*=""
  let @+=""
  let @/=""
endfunction "}}}
command! RegistersClear call s:RegistersClear()

"diff"{{{
" from $VIMRUNTIME/vimrc_example.vim
" see diff-original-file
command! DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
"kaoriya
command! -nargs=1 -complete=file VDsplit vertical diffsplit <args>
command! -nargs=0 Undiff windo set nodiff noscrollbind nocursorbind foldcolumn=1

command! DiffWindo windo diffthis
nnoremap <Leader>dw :DiffWindo<CR>
"command! -nargs=+ -complete=buffer DiffBuffers vertical diffsplit <args>
"}}}

"Native2ascii"{{{
function! s:Native2ascii(first, last, bang)
  if executable('native2ascii')
    silent execute a:first . ',' . a:last . '!native2ascii -encoding UTF-8'.(a:bang == '!' ? ' -reverse' : '')
  else
    call EchoError('"native2ascii" does not exist')
  endif
endfunction
command! -nargs=0 -range=% Native2asciiReverse call s:Native2ascii(<line1>, <line2>, '!')
command! -bang -nargs=0 -range=% Native2ascii call s:Native2ascii(<line1>, <line2>, '<bang>')
"}}}

function! s:UniqLine(first,last) "{{{
  if exists('*uniq')
    let l:uniqLine = uniq(getline(a:first, a:last))
    execute a:first . ',' . a:last . 'delete _'
    call append(a:first - 1, l:uniqLine)
  elseif executable('uniq')
    silent execute a:first . ',' . a:last . '!uniq'
  else
    call EchoError('"uniq" does not exist')
  endif
endfunction "}}}
command! -range=% Uniq call s:UniqLine(<line1>, <line2>)

function! s:Reverse(first,last) "{{{
  let l:reverse = reverse(getline(a:first, a:last))
  silent execute a:first . ',' . a:last . 'delete _'
  call append(a:first - 1, l:reverse)
endfunction "}}}
command! -range=% Reverse call s:Reverse(<line1>, <line2>)

comman! Capitalize %s/./\l&/g|%s/_./\L\U&/g|%s/_//g

function! DecodeJson(url, ...) "{{{
  let l:url = a:url
  let l:settings = get(a:000, 0, {})

  let l:V = VitalWrapper('Web.HTTP', 'Web.JSON')
  let l:res = l:V.Web.HTTP.request(l:url, l:settings)
  if !get(l:res, 'success', 0)
    return l:res
  endif
  let l:content = get(l:res, 'content', '')
  return l:V.Web.JSON.decode(l:content)
endfunction "}}}
command! VimPatches PP DecodeJson('http://vim-jp.herokuapp.com/patches/json')
command! RssVimJp PP map(webapi#feed#parseURL('http://vim-jp.org/rss.xml'), 'get(v:val, "title")')

"TODO replace Vital.Vim.BufferManager
"let g:m = g:vital.Vim.BufferManager.new()
"echo g:m.open('test')
function! MakeBuf(bufname, ...) "{{{
  let l:options = {}
  if !empty(a:000) && type(a:1) == type({})
    let l:options = a:1
  endif
  let l:bufname = a:bufname
  let l:bufnr = bufnr(l:bufname)
  let l:bufwinnr = bufwinnr(l:bufnr)
  if l:bufwinnr >= 0
    if l:bufwinnr != bufwinnr('%')
      exe l:bufwinnr . 'wincmd w'
    endif
  else
    exe 'vnew '.l:bufname
  endif
  "let b:{l:bufname} = l:bufname
endfunction "}}}

"tailread"{{{
"参考
"head.vim : ファイルの上か下、限定された行数のみを読み込む — 名無しのvim使い
"http://nanasi.jp/articles/vim/head_vim.html
"http://nanasi.jp/articles/code/sample/head.vim.html
let g:tailLines = 50
function! TailRead(path, bang) "{{{
  if exists('b:tail_file_path')
    let l:file = b:tail_file_path
  else
    let l:file = fnamemodify(expand(a:path), ':p')

    " 実際に読む込むべきファイルのパスを取得
    let l:prot = matchstr(l:file, ';\(tail\)$')
    if !empty(l:prot)
      let l:file = strpart(l:file, 0, strlen(l:file) - strlen(l:prot))
    endif
  endif

  " バッファを作る
  let l:tempEventIgnore = &eventignore
  try
    let &eventignore = 'all'
    call MakeBuf(l:file.';tail')
  finally
    let &eventignore = l:tempEventIgnore
  endtry
  setlocal modifiable
  silent %d _
  " ファイルを読み込んで、バッファにセットする。
  if filereadable(l:file)
    if a:bang == '!'
      call setline(1, readfile(l:file))
      " call setline(1, map(readfile(l:file), 'Incoming(v:val)'))
    else
      call setline(1, readfile(l:file, '', get(g:, 'tailLines', 10) * -1))
      " call setline(1, map(readfile(l:file, '', get(g:, 'tailLines', 10) * -1), 'Incoming(v:val)'))
    endif
  else
    call setline(1, printf('ERROR!!! filereadable(%s)', l:file))
  endif
  let b:tail_file_path = l:file

  setlocal noswapfile
  setlocal buftype=nofile
  setlocal filetype=tail
  setlocal nomodifiable
  nnoremap <silent> <buffer> <F5> :<C-u>TailRead %<CR>
  nnoremap <silent> <buffer> <S-F5> :<C-u>TailRead! %<CR>
  command! -buffer TailReadOrig exe 'tabe '.b:tail_file_path
  exe 'normal! G'
endfunction "}}}

command! -bang -nargs=1 -complete=file TailRead call TailRead(<f-args>, '<bang>')
if !exists('#Tail')
  augroup Tail
    autocmd!
    execute ":autocmd BufReadCmd   *;tail,*/*;tail TailRead <afile>"
    execute ":autocmd FileReadCmd  *;tail,*/*;tail TailRead <afile>"
  augroup END
endif
"}}}

function! s:SendIpmsg(first, last, bang, args) range "{{{
  if !executable('powershell')
    return
  endif
  let l:V = VitalWrapper('Prelude', 'System.Filepath', 'Process')
  if !l:V.Prelude.is_windows()
    return
  endif

  call l:V.Prelude.set_default('g:ipmsg_path', 'ipmsg.exe')

  let l:ipmsgPath = l:V.System.Filepath.winpath(g:ipmsg_path)
  if !executable(l:ipmsgPath)
    return
  endif

  let l:hostname = empty(a:args) ? 'localhost' : a:args

  let l:tmpfile = l:V.System.Filepath.winpath(tempname().'.ps1')

  let l:write = []
  call add(l:write, "$message = @'")

  let l:lineList = getline(a:first, a:last)
  for l:line in l:lineList
    if l:line ==# "'@"
      call add(l:write, "'@ + @\"")
      call add(l:write, '')
      call add(l:write, "'@")
      call add(l:write, '')
      call add(l:write, "\"@ + @'")
    else
      call add(l:write, Outgoing(l:line))
    endif
  endfor
  call add(l:write, '')
  call add(l:write, "'@")
  call add(l:write, '')

  let l:exeStr = 'Start-Process -FilePath "%s" -Wait -ArgumentList "/MSG %s %s $message"'
  let l:exeStr = printf(l:exeStr, l:ipmsgPath, (a:bang ==# '!' ? '' : '/LOG /SEAL'), l:hostname)
  call add(l:write, l:exeStr)

  call writefile(l:write, l:tmpfile)

  let l:execute = l:V.Process.system(printf('powershell -File "%s"', l:tmpfile))
  echo l:execute
  call delete(l:tmpfile)

endfunction "}}}

function! GetHostName(ArgLead, CmdLine, CursorPos) abort "{{{
  return join(get(g:, 'ipmsg_host_list', ['localhost']), "\n")
endfunction "}}}
command! -complete=custom,GetHostName -bang -range=% -nargs=? Ipmsg call s:SendIpmsg(<line1>, <line2>, '<bang>', <q-args>)

"Scratch"{{{
function! Scratch(filetype) "{{{
  for n in range(10)
    if !bufexists('__scratch__@'.n)
      execute 'file __scratch__@'.n
      break
    endif
  endfor
  unlet n
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  if empty(a:filetype)
    setfiletype scratch
  else
    exe printf('setfiletype %s', a:filetype)
  endif
  doautocmd BufNewFile
endfunction "}}}
command! -complete=filetype -nargs=? VScratch vnew | call Scratch(<q-args>)
command! -complete=filetype -nargs=? ScratchThis call Scratch(<q-args>)
nnoremap <Leader>vs :<C-u>VScratch<Space>
nnoremap <Leader>E :<C-u>tab new<CR>:ScratchThis<Space>
"}}}

function! EchoWarning(msg) "{{{
  redraw
  execute 'echohl WarningMsg'
  execute 'echomsg "[.vimrc]"'.string(a:msg)
  execute 'echohl None'
endfunction "}}}
function! EchoError(msg) "{{{
  redraw
  execute 'echohl ErrorMsg'
  execute 'echomsg "[.vimrc]"'.string(a:msg)
  execute 'echohl None'
endfunction "}}}

function! Source(file, ...) "{{{
  if filereadable(expand(a:file))
    execute 'source '.a:file
  elseif empty(a:000) || a:1 isnot 1
    call add(g:messages, a:file)
  endif
endfunction "}}}

command! RestoreUpdatetime let &updatetime = g:update_time

" sudo "{{{
if g:is_windows && has('clientserver') && (executable('sudow') || executable('sudo'))
  let s:sudo_bin = executable('sudow') ? 'sudow' : 'sudo'
  let s:sudo_cmd = printf('!start %s %%s --servername %s %%%%', s:sudo_bin, s:sudo_bin)
  command! SudoVim execute printf(s:sudo_cmd, 'vim')
  if has('gui_running')
    command! SudoGvim execute printf(s:sudo_cmd, 'gvim')
  endif
endif
"}}}

"MultiMap:"{{{
"TODO plugin化
let g:MultiMapFile = fnamemodify(g:sfile_path, ':h') . '/MultiMap.vim'
if has('vim_starting') && filereadable(g:MultiMapFile)
  let g:MultiMapChar = '<Leader>t'
  nnoremap <Leader>tM :<C-U>MultiMap<CR>
  command! MultiMap call Source(g:MultiMapFile)|call MultiMap()
endif
"}}}

" @see QuickFixCmdPost-example
function! QfMakeConv() "{{{
  let l:qflist = getqflist()
  for i in l:qflist
    let i.text = Incoming(i.text)
  endfor
  unlet i
  call setqflist(l:qflist)
endfunction "}}}

function! Timer() "{{{
  if exists('s:start_time')
    echomsg reltimestr(reltime(s:start_time))
    unlet s:start_time
  else
    let s:start_time = reltime()
  endif
endfunction "}}}

function! UnmapBuffer(name, mode) "{{{
  let l:map = maparg(a:name, a:mode, 0, 1)
  if !empty(l:map) && l:map.buffer is 1
    execute a:mode.'unmap <buffer> '.a:name
  endif
endfunction "}}}

" Restart
if has('gui_running')
  nnoremap <Leader>res :<C-u>:wviminfo!<Cr>:silent !start gvim<Cr>:qall<Cr>
  if s:neobundle_is_installed
    nnoremap <Leader>RES :<C-u>NeoBundleClearCache<Cr>:wviminfo!<Cr>:silent !start gvim<Cr>:qall<Cr>
  else
    nnoremap <Leader>RES :<C-u>wviminfo!<Cr>:silent !start gvim<Cr>:qall<Cr>
  endif
else
  nnoremap <Leader>res :<C-u>call EchoWarning('not supported')<Cr>
  nnoremap <Leader>RES :<C-u>call EchoWarning('not supported')<Cr>
endif

"}}}
"-----------------------------------------------------------------------------
"Finalization:"{{{
if has('vim_starting')
  call Source('$VIMRUNTIME/delmenu.vim')
  if has('gui_running') && !argc()
    cd $HOME
  endif
else
  if s:neobundle_is_installed
    call neobundle#call_hook('on_source')
    call neobundle#call_hook('on_post_source')
  endif
endif

call Source('$VIMFILES/.vimrc_local.vim', 1)
call Source('$VIMFILES/vimrc_local.vim', 1)

if len(g:messages) > 0
  augroup lazy-starting-msg
    autocmd!
    autocmd CursorHold,CursorHoldI,FocusLost * call map(g:messages, 'EchoError(v:val)')
      \| exe 'autocmd! lazy-starting-msg'
  augroup END
endif

"}}}
"-----------------------------------------------------------------------------
" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
