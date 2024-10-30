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
  let g:is_android = exists('$ANDROID_ROOT')
  lockvar g:is_android
  let g:is_msys = !empty($MSYSTEM)
  lockvar g:is_msys

  let g:inside_tmux = !empty($TMUX)
  lockvar g:inside_tmux
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
function! s:SID_PREFIX() abort
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zeSID_PREFIX$')
endfunction
let g:vimrc_sid = s:SID_PREFIX()

let s:has_kaoriya = has('kaoriya')

if g:is_windows
  let g:drive_letter = g:sfile_path[0]
endif

function! s:nop()
endfunction
augroup MyAutoCmd
  autocmd!
  autocmd QuickFixCmdPre,QuickFixCmdPost * call s:nop()
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
endfunction "}}}

"}}}
"-----------------------------------------------------------------------------
"Encoding:"{{{
if has('vim_starting')
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
if exists("*mkdir")
  function! Mkdir(path) "{{{
    let l:path = expand(a:path)
    if !isdirectory(l:path)
      if mkdir(l:path, 'p')
        echomsg "mkdir " .. l:path
      endif
      return mkdir(l:path, 'p')
    endif
  endfunction "}}}
else
  function! Mkdir(path) "{{{
    call vimrc#util#error('Not available mkdir()')
    return 0
  endfunction "}}}
endif

function! Getdir(new, old) "{{{
  if isdirectory(expand(a:old))
    call add(g:messages, a:old)
    return a:old
  else
    return a:new
  endif
endfunction "}}}

function! ConvEnvPath(path) "{{{
  return fnamemodify(expand(a:path), g:rep_path .
    \ (g:is_windows ? ':s?[\\/]$??:s?:$?:\\?' : ':s?[\/]$??'))
endfunction "}}}

" VIM: "{{{
if has('vim_starting')

  if has('nvim')
    let $VIMFILES = expand('$XDG_CONFIG_HOME/nvim')
  else
    let $VIMFILES = expand('$HOME/' . (g:is_windows ? 'vimfiles' : '.vim'))
  endif

  let g:vimrc_cache = exists('$XDG_CACHE_HOME') ?
    \ '$XDG_CACHE_HOME/vimrc' :
    \ '$HOME/.cache/vimrc'
  let g:vimrc_data = exists('$XDG_DATA_HOME') ?
    \ '$XDG_DATA_HOME/vimrc' :
    \ '$HOME/.local/share/vimrc'
  let $VIMBUNDLE = expand(Getdir(g:vimrc_data.'/bundle', '$VIMFILES/bundle'))
  call Mkdir($VIMBUNDLE)

  let $VIMDICT = expand('$VIMFILES/dict')
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

endif
function! Source(file, ...) "{{{
  if filereadable(expand(a:file))
    execute 'source '.a:file
  elseif empty(a:000) || a:1 isnot 1
    call add(g:messages, a:file)
  endif
endfunction "}}}
if has('vim_starting') "{{{
  " set pythonthreedll
  call Source('$VIMFILES/vimrc_init_local.vim', 1)
endif "}}}

"}}}
"-----------------------------------------------------------------------------
"Global Variabl:"{{{
let g:memo_dir = expand('$HOME/Documents/memo/')
if isdirectory(expand('$HOME/.bk'))
  let g:backup_dir = expand('$HOME/.bk')
else
  let g:backup_dir = expand(Getdir(g:vimrc_data.'/bk', '$VIMFILES/tmp/bk'))
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

endif
"}}}

"}}}
"-----------------------------------------------------------------------------
"Misc:{{{

set clipboard&
if g:is_windows || has('gui_running') || has('clipboard')
  set clipboard=unnamed
  if has('gui_running')
    if has('unnamedplus')
      set clipboard+=unnamedplus
    endif
  elseif !has('nvim')
    set clipboard+=exclude:.*
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
  let &undodir = expand(Getdir(g:vimrc_cache.'/undodir', '$VIMFILES/tmp/undodir'))
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
  set backupskip+=無題.txt,新しいテキスト\ ドキュメント.txt
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
  for target in split(substitute(&backupskip,'\\', '/', 'g'), ',')
    execute ':autocmd BufWritePre '.target.' let b:backup_skip = 1'
  endfor
  unlet target
  autocmd BufWritePre * call s:SetBackupDir()
augroup END "}}}
"}}}
"-----------------------------------------------------------------------------
"File:{{{
set swapfile
let &directory = expand(Getdir(g:vimrc_cache.'/swap//', '$VIMFILES/tmp/swap//'))
call Mkdir(&directory)
set updatecount=100
augroup MyAutoCmd
  autocmd WinEnter * if (&l:readonly || !&l:modifiable || !empty(&l:buftype)) && &l:swapfile | setl noswapfile | endif
  let s:path = [g:vimrc_cache . '/**', g:vimrc_data . '/**', '$VIMFILES/tmp/**', g:backup_dir.'/**']
  exe printf('autocmd BufRead %s if &swapfile | setl noswapfile | endif', join(s:path, ','))
  unlet s:path
augroup END

"TODO noautoread時にw11を回避する方法
set autoread
set hidden

set diffopt=filler,vertical
if HasVersion('8.1.2289')
  set diffopt+=closeoff
  endif

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
  set viminfo+=/10
  set viminfo+=@5
  set viminfo+=%
  set viminfo+=!
  set viminfo+=c
  if g:is_windows
    set viminfo+=rA:,rB:,rX:,rS:,rT:,rQ:,rU:,rJ:
  endif
    execute printf('set viminfo+=n%s/%s',
      \ expand(Getdir(g:vimrc_cache, '$VIMFILES/tmp')),
      \ has('nvim') ? '.nviminfo' : '.viminfo')
endif

"}}}

let &viewdir=expand(Getdir(g:vimrc_cache . '/view', '$VIMFILES/tmp/view'))
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
  let s:path = ['$VIMRUNTIME/**', g:backup_dir.'/**', '$VIMBUNDLE/**',
    \ '$VIMFILES/autoload/vital/**']
  exe printf('autocmd BufRead %s setlocal nomodifiable', join(s:path, ','))
  unlet s:path
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

if HasVersion('8.1.1564')
  set signcolumn=number
endif

if has('gui_running') && &encoding ==? 'utf-8'
  "echo char2nr('↵', 1)
  "echo nr2char(8629, 1)
  set listchars=tab:>\ ,extends:>,precedes:<,eol:↵,trail:-,nbsp:%
else
  set listchars=tab:>\ ,precedes:<,extends:>,eol:\ ,trail:-,nbsp:%
endif
set list

set fillchars=stl:\ ,stlnc:\ ,vert:\ ,fold:\ ,diff:\ 

set lazyredraw

" autocmd MyAutoCmd VimEnter * if !argc() | tab ball|tabfirst |endif

"}}}
"-----------------------------------------------------------------------------
"Terminal:"{{{
set novisualbell
set t_vb=
if HasVersion('7.4.793')
  set belloff=all
endif
if !has('gui_running')
  if has('mouse') && !has('nvim')
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
  if &term =~? "^(xterm|screen)" || &term =~? "^.*256.*$"
    set t_Co=256
  else
    set t_Co=16
  endif
  set t_BE=
  " " https://ttssh2.osdn.jp/manual/ja/usage/tips/vim.html
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
  \   "t"  : ['TERMINAL','%#StatusLineModeMsgTE#'],
  \   "nt" : ['N-TERMINAL','%#StatusLineModeMsgNT#'],
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
  if g:_dein_is_installed
    let l:ret.=dein#get_progress()
  endif
  if exists('*LspStatusLine')
    let l:ret.=LspStatusLine()
  endif
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
let g:TabLineSep = (has('gui_running') ? ' | ' : ' ') "'┆¦|⋮'

" let s:date_string = '['.strftime("%Y/%m/%d(%a)").']'
function! TabLine() "{{{
  let l:titles = map(range(1, tabpagenr('$')), 's:tabpage_label(v:val)')
  let l:sep = '%#TabLineSep#' . get(g:, 'TabLineSep', ' ')
  let l:tabpages = ' ' . join(l:titles, l:sep) . l:sep . '%#TabLineFill#%T'
  let l:info = '%#TabLineInfo#'

  "カレントディレクトリ
  if !g:is_android
    let l:colors_name = get(g:, 'colors_name', '')
    " let l:info .= s:date_string
    let l:info .= &paste ? '%#TabLineMod#[past]%#TabLineInfo#' : ''
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

"command-line{{{
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <M-b> <S-Left>
cnoremap <M-f> <S-Right>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
"}}}

"command-line window{{{
noremap : ;
function! Save_window_value()
  let g:cword = expand('<cword>')
  let g:buffer_name = expand('%')
endfunction
noremap ; :
noremap q; :<C-u>call Save_window_value()<CR>q:
noremap <Leader>; :<C-u>call Save_window_value()<CR>q:
vnoremap q; q:
vnoremap <Leader>; q:

"Vim-users.jp - Hack #161: Command-line windowを使いこなす
"http://vim-jp.org/vim-users-jp/2010/07/14/Hack-161.html
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
  setlocal signcolumn=no
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
  " inoremap <buffer> kk <Esc>k
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
    call vimrc#util#warn(v:exception)
  catch /^Vim\%((\a\+)\)\=:E19/
    redraw
    call vimrc#util#warn(v:exception)
  endtry
endfunction "}}}
"}}}

"buffer{{{
nnoremap <silent> <Leader>bn :<C-u>bn<CR>
nnoremap <silent> <Leader>bp :<C-u>bp<CR>
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
nnoremap <silent> <Leader>tt :<C-u>call <SID>SwitchTab('m', 1)<CR>
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
  noremap q/ :<C-u>let g:cword = expand('<cword>')<CR>q/
  noremap <Leader>/ :<C-u>let g:cword = expand('<cword>')<CR>q/
  noremap <Leader>?? q?
endif
"}}}

"Substitute"{{{
nnoremap <Leader>rr :%s//geI#<Left><Left><Left><Left><Left>
vnoremap <Leader>rr :s//geI#<Left><Left><Left><Left><Left>
"}}}

"global"{{{
nnoremap <Leader>gg :%g//normal<Space>
vnoremap <Leader>gg :g//normal<Space>
nnoremap <Leader>GG :%g!//normal<Space>
vnoremap <Leader>GG :g!//normal<Space>
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
nnoremap <silent> <F5> :<C-u>e<CR>
nnoremap <silent> <S-F5> :<C-u>noautocmd e<CR>

nnoremap <silent> <Leader>sp :<C-u>setlocal spell!<CR>:setlocal spell?<CR>

if has('terminal')
  tnoremap <C-Insert> <C-w>N
  tnoremap <S-Insert> <C-w>"*

  "like tmux
  tnoremap <C-b>n <C-w>w
  tnoremap <C-b>p <C-w>W
  tnoremap <C-b>[ <C-w>N
  tnoremap <C-b>] <C-w>"*
endif

"}}}
"-----------------------------------------------------------------------------
"Plugin:"{{{
"dein.vim Install"{{{
if has('vim_starting') && (HasVersion('8.0') || has('nvim')) && !g:is_view
  let s:dein_path = expand('$VIMBUNDLE/repos/github.com/Shougo/dein.vim')
  if !isdirectory(s:dein_path)
    if executable('git')
      exe '!git clone https://github.com/Shougo/dein.vim' .' '.s:dein_path
    endif
  endif
  if filereadable(s:dein_path . '/autoload/dein.vim')
    let &runtimepath .= (',' . s:dein_path)
  endif
endif

let g:_dein_is_installed = (&rtp =~? 'dein\.vim')
"}}}

if g:_dein_is_installed "{{{
  "dein{{{
  let g:dein#install_log_filename = expand(g:vimrc_data . '/dein.log')
  let g:dein#install_progress_type = "none"
  " if g:is_windows
    " let s:numberOfProcessors = str2float($NUMBER_OF_PROCESSORS)
    " let g:dein#install_max_processes = float2nr(ceil(s:numberOfProcessors / 2))
  " endif
  "}}}
  let g:plugin_disable_filetypes =
    \ ['help', 'unite', 'defx', 'log', 'text', 'calendar', 'ref',
    \  'quickrun', 'tail']

endif "}}}

" dein "{{{
let s:base_path = expand('$VIMBUNDLE')
if g:_dein_is_installed && dein#load_state(s:base_path)

  let s:event_idle = ['FocusLost', 'CursorHold']
  let s:event_i = ['InsertEnter']

  call dein#begin(s:base_path) "filetype off

  call dein#add('Shougo/dein.vim')

  call dein#add('prabirshrestha/asyncomplete.vim',{
    \   'merged': 0,
    \   'on_event' : s:event_idle + s:event_i
    \ })
  call dein#load_dict({
    \   'prabirshrestha/asyncomplete-buffer.vim': {},
    \   'prabirshrestha/asyncomplete-file.vim': {},
    \   'prabirshrestha/asyncomplete-neosnippet.vim': {},
    \   'prabirshrestha/asyncomplete-emmet.vim': {},
    \   'Shougo/neco-syntax': {'lazy' : 1},
    \   'prabirshrestha/asyncomplete-necosyntax.vim': {},
    \   'Shougo/neco-vim': {'lazy' : 1},
    \   'prabirshrestha/asyncomplete-necovim.vim': {},
    \   'yami-beta/asyncomplete-omni.vim': {},
    \   'prabirshrestha/vim-lsp': {'lazy' : 1, 'augroup': 'lsp_auto_enable'},
    \   'mattn/vim-lsp-settings': {'lazy' : 1},
    \   'prabirshrestha/asyncomplete-lsp.vim': {'lazy' : 1},
    \   'thomasfaingnaert/vim-lsp-snippets': {'lazy' : 1},
    \   'thomasfaingnaert/vim-lsp-neosnippet': {'lazy' : 1},
    \ }, {'on_source': 'asyncomplete.vim', 'lazy' : 0}
    \ )

  "Shougo/vimproc{{{
  call dein#add('Shougo/vimproc', {
    \   'if' : !g:is_android,
    \   'on_source' : ['unite.vim', ],
    \   'on_cmd' : [ 'VimProcInstall', 'VimProcBang', 'VimProcRead',],
    \   'on_func' : 'vimproc#',
    \   'on_event' : s:event_idle + s:event_i
    \ })
  if !g:is_windows
    call dein#config('vimproc', {'build': 'make'})
  endif
  "}}}

  call dein#add('Shougo/tabpagebuffer.vim', {
    \   'on_source' : ['unite.vim', ],
    \ })

  call dein#add('vim-jp/vimdoc-ja', {'lazy': 0,})
  call dein#add('chrisbra/vim_faq', {'lazy': 1,})

  "Shougo/unite.vim{{{
  call dein#add('Shougo/unite.vim', {
    \   'on_cmd' : [ 'Unite', 'UniteWithCursorWord',
    \                'UniteWithInput', 'UniteWithBufferDir', ],
    \ })
  "}}}

  "unite_sources{{{
  call dein#load_dict({
    \   'Shougo/neoyank.vim': {'on_event' : s:event_idle},
    \   'Shougo/unite-build': {},
    \   'thinca/vim-unite-history': {},
    \   'osyo-manga/unite-fold': {},
    \   'osyo-manga/unite-quickfix': {},
    \   'pasela/unite-webcolorname': {},
    \   'Shougo/unite-help': {},
    \   'Shougo/unite-outline': {},
    \   'sgur/unite-everything': {'if': executable('es.exe')},
    \   'ujihisa/unite-locate': {'if': executable('locate')},
    \ }, {'on_source': 'unite.vim'}
    \ )
  "}}}

  call dein#add('lambdalisue/mr.vim', {
    \   'rev': 'v1.1.0',
    \   'on_event': s:event_idle + s:event_i,
    \   'on_func' : 'mr#',
    \ })

  "osyo-manga/vim-precious"{{{
  call dein#add('osyo-manga/vim-precious', {
    \   'on_cmd' : ['PreciousSwitch',  'PreciousSwitchAutcmd', ],
    \   'on_func' : 'precious#',
    \ })
  "}}}

  "Shougo/context_filetype.vim"{{{
  call dein#add('Shougo/context_filetype.vim', {
    \   'on_func' : 'context_filetype#',
    \   'on_source' : ['vim-precious', ],
    \ })
  "}}}

  "Shougo/neosnippet{{{
  call dein#add('Shougo/neosnippet', {
    \   'on_event' : s:event_i,
    \   'depends' : 'neosnippet-snippets',
    \   'on_ft' : ['snippet'],
    \   'on_source' : ['unite.vim', 'asyncomplete.vim', ],
    \   'on_func' : 'neosnippet#expandable_or_jumpable',
    \ })
  "}}}

  call dein#load_dict({
    \   'Shougo/neosnippet-snippets': {},
    \   'honza/vim-snippets': {},
    \ }, {'on_source' : ['neosnippet'],
    \ })

  "mattn/sonictemplate-vim"{{{
  call dein#add('mattn/sonictemplate-vim', {
    \   'on_cmd' : [ 'Template', ],
    \   'on_map' : '<plug>(sonictemplate',
    \   'on_source' : ['unite.vim', ],
    \ })
  "}}}
  "sonictemplate-vim-templates{{{
  call dein#add('nakahiro386/sonictemplate-vim-templates', {
    \   'on_source' : ['sonictemplate-vim', ],
    \ })
  "}}}

  "mattn/emmet-vim{{{
  call dein#add('mattn/emmet-vim', {
    \   'on_ft' : ['xhtml', 'html', 'css', 'javascript'],
    \   'on_source' : ['unite.vim', ],
    \   'on_func' : 'emmet#',
    \ })
  "}}}

  "thinca/vim-ambicmd{{{
  call dein#add('thinca/vim-ambicmd', {
    \   'on_event' : s:event_i,
    \   'on_ft' : 'vim',
    \   'on_func' : 'ambicmd#',
    \ })
  "}}}

  "cohama/lexima.vim{{{
  call dein#add('cohama/lexima.vim', {
    \   'on_event' : s:event_i,
    \   'if' : 0,
    \ })
  "}}}
  "tpope/vim-endwise{{{
  call dein#add('tpope/vim-endwise', {
    \   'on_event' : s:event_i,
    \ })
  "}}}
  call dein#add('raimondi/delimitmate', {
    \   'on_event' : s:event_i,
    \ })

  call dein#add('obaland/vfiler.vim', {
    \   'if': (has('lua') && HasVersion('8.2')) || has('nvim-0.5.0') ,
    \   'on_cmd': 'VFiler',
    \   'on_event': s:event_idle + s:event_i,
    \   'on_path' : '.*',
    \ })

  call dein#add('Shougo/defx.nvim', {
    \   'if': has('nvim') || (has('timers') && HasVersion('8.0')),
    \   'on_cmd': 'Defx',
    \ })
  call dein#load_dict({
    \ 'roxma/nvim-yarp': {},
    \ 'roxma/vim-hug-neovim-rpc': {},
    \ }, {
    \   'if': !has('nvim'),
    \   'on_source': ['defx.nvim'],
    \ }
    \ )

  "thinca/vim-prettyprint{{{
  call dein#add('thinca/vim-prettyprint', {
    \   'on_cmd' : ['PP', 'PrettyPrint'],
    \   'on_func' : ['PP', 'PrettyPrint'],
    \ })
  "}}}

  call dein#add('taku-o/vim-batch-source', { 'on_cmd' : 'Batch', })

  "which.vim 1.0{{{
  call dein#add('vim-scripts/which.vim', {
    \   'frozen' : 1,
    \   'on_func' : 'Which',
    \   'on_cmd'  : 'Which',
    \ })
  "}}}

  call dein#add('tyru/capture.vim', {'on_cmd' : 'Capture'})

  "scrooloose/nerdcommenter{{{
  call dein#add('scrooloose/nerdcommenter', {
    \   'on_map' : '<plug>NERDCommenter',
    \ })
  "}}}

  "nakahiro386/vim-rectinsert{{{
  call dein#add('nakahiro386/vim-rectinsert', {
    \   'on_map' : [['nx', '<Plug>', ]],
    \ })
  "}}}

  call dein#add('AndrewRadev/switch.vim', { 'on_cmd' : 'Switch', })

  call dein#add('lambdalisue/gina.vim', {'on_cmd': ['Gina']})

  "Align "{{{
  call dein#add('vim-scripts/Align', {
    \   'frozen' : 1,
    \   'on_cmd' : 'Align'
    \ })
  "}}}

  "t9md/vim-quickhl{{{
  call dein#add('t9md/vim-quickhl', {
    \   'if' : has('gui_running'),
    \   'on_map' : [
    \     ['nx', '<Plug>(quickhl-manual-this)',
    \            '<Plug>(quickhl-cword-toggle)', ],
    \   ],
    \ })
  "}}}

  "t9md/vim-textmanip{{{
  call dein#add('t9md/vim-textmanip', {
    \   'on_map' :  [['nx', '<Plug>', ]],
    \ })
  "}}}

  "t9md/vim-choosewin{{{
  call dein#add('t9md/vim-choosewin', {
    \   'on_map' : '<Plug>',
    \   'on_cmd' : 'ChooseWin',
    \   'augroup': 'plugin-choosewin',
    \   'on_source': ['defx.nvim'],
    \ })
  "}}}

  "nathanaelkane/vim-indent-guides{{{
  call dein#add('nathanaelkane/vim-indent-guides', {
    \   'on_map' : [['n', '<Plug>IndentGuidesToggle',
    \                       '<Plug>IndentGuidesEnable',
    \                       '<Plug>IndentGuidesDisable',], ],
    \   'on_cmd' : ['IndentGuidesEnable', 'IndentGuidesToggle'],
    \ })
  "}}}
  "nakahiro386/number-marks{{{
  call dein#add('nakahiro386/number-marks', {
    \   'on_map' : [['n', '<Plug>Place_sign',], ],
    \ })
  "}}}

  "colorsel.vim{{{
  call dein#add('vim-scripts/colorsel.vim', {
    \   'frozen' : 1,
    \   'gui' : 1,
    \   'on_cmd' : 'ColorSel'
    \ })
  "}}}

  "lilydjwg/colorizer{{{
  call dein#add('lilydjwg/colorizer', {
    \   'on_cmd' : ['ColorHighlight', 'ColorToggle']
    \ })
  "}}}

  "osyo-manga/vim-anzu{{{
  call dein#add('osyo-manga/vim-anzu', {
    \   'on_map' : '<Plug>',
    \   'on_cmd' : 'AnzuClearSearchStatus',
    \ })
  "}}}

  "easymotion/vim-easymotion {{{
  call dein#add('easymotion/vim-easymotion', {
    \   'on_map' : ['<Plug>', 's'],
    \ })
  "}}}

  "rhysd/clever-f.vim{{{
  call dein#add('rhysd/clever-f.vim', {
    \   'on_map' : ['f','F','t','T']
    \ })
  "}}}

  "matchit.zip{{{
  call dein#add('vim-scripts/matchit.zip' , {
    \   'frozen' : 1,
    \   'on_ft' : ['vim', 'HTML', 'xhtml', 'xml', 'jsp', ],
    \   'on_map' : ['%', 'g%', ],
    \ })
  "}}}

  "osyo-manga/vim-milfeulle{{{
  call dein#add('osyo-manga/vim-milfeulle', {
    \   'on_map' : [['n', '<Plug>']],
    \   'on_cmd' : ['MilfeulleDisp', 'MilfeullePrev', 'MilfeulleNext', 'MilfeulleClear',
    \                 'MilfeulleRefreshMilfeulleRefresh', 'MilfeulleOverlay'],
    \   'on_event' : s:event_idle,
    \ })
  "}}}

  " vim-textobj-user"{{{
  "kana/vim-textobj-user{{{
  call dein#add('kana/vim-textobj-user', {
    \   'lazy': 0,
    \   'on_func' : 'textobj#user#',
    \ })
  "}}}

  call dein#load_dict({
    \   'kana/vim-textobj-fold': {},
    \   'kana/vim-textobj-indent': {},
    \   'osyo-manga/vim-textobj-multiblock': {},
    \   'thinca/vim-textobj-between': {},
    \ }, {
    \   'on_source' : ['vim-textobj-user'],
    \   'on_map' : [['xo', '<Plug>'], '<Plug>'],
    \ })

  "}}}

  call dein#add('nakahiro386/fullwidth-halfwidth.vim',
    \   {'on_cmd': ['FullwidthAscii', 'HalfwidthAscii']}
    \ )

  " vim-operator-user"{{{
  "kana/vim-operator-user{{{
  call dein#add('kana/vim-operator-user', {
    \   'lazy': 0,
    \   'on_func' : 'operator#user#',
    \ })
  "}}}

  call dein#load_dict({
    \   'kana/vim-operator-replace': {},
    \   'rhysd/vim-operator-surround': {},
    \   'mopp/vim-operator-convert-case': {
    \     'on_map' : '<Plug>(operator-convert-case-'
    \   },
    \   'tyru/operator-html-escape.vim': {
    \     'on_map' : '<Plug>(operator-html-'
    \   },
    \ }, {
    \   'on_source' : ['vim-operator-user'],
    \   'on_map' : '<Plug>',
    \ })

  "}}}

  "fuenor/im_control.vim{{{
  call dein#add('fuenor/im_control.vim', {
    \   'on_func' : ['IMState', 'IMCtrl', ],
    \ })
  "}}}

  "pepo-le/win-ime-con.nvim{{{
  call dein#add('pepo-le/win-ime-con.nvim', {
    \   'if': has('nvim'),
    \ })
  "}}}

  "tpope/vim-capslock {{{
  let g:capslock_filetype = ['sql', 'dosbatch']
  call dein#add('tpope/vim-capslock', {
    \   'on_map' : [['n', '<Plug>CapsLockToggle', ], ],
    \   'on_ft' : g:capslock_filetype,
    \   'on_cmd' : ['CapsLockToggle', 'CapsLockEnable', 'CapsLockDisable'],
    \ })
  "}}}

  call dein#add('vim-jp/vital.vim', {
    \   'on_cmd' : 'Vitalize',
    \   'on_func' : 'vital#',
    \ })
  call dein#load_dict({
    \   'lambdalisue/vital-Whisky': {},
    \ }, {'on_source': 'vital.vim'}
    \ )

  "thinca/vim-scouter{{{
  call dein#add('thinca/vim-scouter', { 'on_cmd' : 'Scouter', })
  "}}}

  "mattn/calendar-vim{{{
  call dein#add('mattn/calendar-vim', {
    \   'on_map' : [['n', '<Plug>CalendarV', '<Plug>CalendarH']],
    \   'on_cmd' : ['Calendar', 'CalendarH'],
    \ })
  "}}}

  "thinca/vim-quickrun{{{
  call dein#add('thinca/vim-quickrun', {
    \   'on_cmd' : ['QuickRun', ],
    \   'on_func' : 'quickrun#',
    \ })
  "}}}

  "tyru/open-browser.vim{{{
  call dein#add('tyru/open-browser.vim', {
    \     'on_map' : [['nx', '<Plug>(openbrowser']],
    \     'on_cmd' : ['OpenBrowser', 'OpenBrowserSearch', 'OpenBrowserSmartSearch'],
    \     'on_func' : 'openbrowser#',
    \     'on_source': ['previm',],
    \ })
  "}}}

  call dein#add('vifm/vifm.vim', {
    \   'on_ft' : ['vifm'],
    \   'on_cmd' : ['Vifm', 'EditVifm', 'VsplitVifm', 'SplitVifm', 'DiffVifm', 'TabVifm'],
    \ })

  call dein#load_dict({
    \   'vim-jp/syntax-vim-ex': {},
    \   'pearofducks/ansible-vim': {},
    \   'hnamikaw/vim-autohotkey': {'frozen' : 1},
    \   'ekalinin/Dockerfile.vim': {},
    \   'sheerun/html5.vim': {},
    \   'pangloss/vim-javascript': {},
    \   'martinda/Jenkinsfile-vim-syntax': {},
    \   'plasticboy/vim-markdown': {},
    \   'chr4/nginx.vim': {},
    \   'aklt/plantuml-syntax': {},
    \   'PProvost/vim-ps1': {},
    \   'vim-scripts/Windows-PowerShell-indent-enhanced': {'frozen' : 1, 'merged': 0},
    \   'Vimjas/vim-python-pep8-indent': {},
    \   'vim-python/python-syntax': {},
    \   'nvie/vim-flake8': {},
    \   'vim-ruby/vim-ruby': {},
    \   'arzg/vim-sh': {},
    \   'wgwoods/vim-systemd-syntax': {},
    \   'ericpruitt/tmux.vim': {},
    \   'cespare/vim-toml': {},
    \   'posva/vim-vue': {},
    \   'vim-scripts/jQuery': {'frozen' : 1, 'merged': 0},
    \   'vim-scripts/XSLT-syntax': {'frozen' : 1},
    \   'stephpy/vim-yaml': {},
    \   'davidoc/taskpaper.vim': {'frozen' : 1},
    \ }, {'lazy': 0}
    \ )

  call dein#load_dict({
    \   'jmcantrell/vim-virtualenv': {'on_ft': ['python']},
    \   'vim-scripts/java_fold': {'on_ft': ['java'], 'frozen': 1},
    \   'theniceboy/fzf-gitignore': {'on_ft': ['gitignore']},
    \   'raimon49/requirements.txt.vim': {'on_ft': ['requirements']},
    \ }, {'lazy': 1}
    \ )

  call dein#load_dict({
    \   'mattn/webapi-vim': {'on_func' : 'webapi#'},
    \   'mattn/wwwrenderer-vim': {'on_func' : 'wwwrenderer#'},
    \   'thinca/vim-openbuf': {'on_func' : 'openbuf#'},
    \ }, {'lazy': 0}
    \ )

  call dein#add('previm/previm', {
    \   'on_ft': ['markdown'],
    \   'on_cmd': ['PrevimOpen', ],
    \   'augroup': 'previm',
    \ })


  call dein#load_dict({
    \   'thinca/vim-qfreplace': {'on_cmd' : ['Qfreplace',]},
    \   'romainl/vim-qf': {},
    \ }, {'on_event': 'QuickFixCmdPre'}
    \ )

  "haya14busa/vim-migemo{{{
  call dein#add('haya14busa/vim-migemo', {
    \   'on_map' : [['n', '<Plug>(migemo-migemosearch)']],
    \   'on_event' : s:event_idle + s:event_i,
    \   'if' : has('migemo') || executable('cmigemo')
    \ })
  "}}}

  call dein#add('mopp/layoutplugin.vim', { 'on_cmd' : 'LayoutPlugin', })

  call dein#add('haya14busa/vim-poweryank', {
    \   'if' : 0,
    \   'on_map' : [['nxo', '<Plug>(operator-poweryank-osc52)']],
    \   'on_cmd' : 'PowerYankOSC52',
    \ })

  call dein#add('ojroques/vim-oscyank', {
    \   'if' : !has('gui_running'),
    \   'on_map' : [['nxo', '<Plug>OSCYank']],
    \   'on_cmd' : ['OSCYank', 'OSCYankVisual', 'OSCYankRegister',],
    \ })

  call dein#add('editorconfig/editorconfig-vim', {'on_cmd': 'EditorConfigEnable'})

  " call dein#save_state()
  call dein#end()
  call dein#save_state()
endif "if g:_dein_is_installed && dein#load_state(g:sfile_path)"}}}

"Tap"{{{
let g:plugins = {}
let g:plugin = {}
if g:_dein_is_installed "{{{
  function! Tap(name) "{{{
    let l:tap = dein#tap(a:name)
    if l:tap
      if !has_key(g:plugins, a:name)
        let g:plugins[a:name] = {}
      endif
      let g:plugin = g:plugins[a:name]
    endif
    return l:tap
  endfunction "}}}
  function! Set_hook(hook_name, hoo_func) "{{{
    return dein#set_hook(g:dein#name, a:hook_name, printf('call g:plugins["%s"]["%s"]()', g:dein#name, a:hoo_func))
  endfunction "}}}
  function! UnTap() "{{{
    unlet g:plugin
    return 0
  endfunction "}}}
else
  function! Tap(name) "{{{
    return 0
  endfunction "}}}
  function! UnTap() "{{{
    return 0
  endfunction "}}}
endif "if g:_dein_is_installed"}}}

if Tap('dein.vim') "{{{
  command! DeinCheckLazyPlugins echo dein#check_lazy_plugins()
  command! DeinCheckClean echo dein#check_clean()
  command! -bang DeinCheckUpdate execute tr('call dein#check_update(<bang>)', '!', '1')

  command! DeinClearState echo dein#clear_state()
  command! DeinRecacheRuntimepath echo dein#recache_runtimepath()
endif "}}}

if Tap('vimproc') "{{{
  if g:is_windows
    let g:vimproc#download_windows_dll = 1
  endif
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
  " echo Download_vimproc_dll('9.3')
  " echo vimproc#util#try_download_windows_dll('9.3')
endif "}}}

if Tap('asyncomplete.vim') "{{{
  function! plugin.on_source() abort "{{{
    let g:asyncomplete_enable_for_all = 1
    set completeopt=menuone,noselect
    let g:asyncomplete_auto_completeopt = 0

    let g:asyncomplete_disable_filetype = g:plugin_disable_filetypes
    execute ':autocmd MyAutoCmd FileType '.join(g:asyncomplete_disable_filetype, ',').' call asyncomplete#disable_for_buffer()'
    " TODO deoplete#mapping#_complete_common_string()

    "tabで補完候補の選択を行う
    inoremap <expr><Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr><S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    imap <expr><C-y>
      \ pumvisible() ?
      \ asyncomplete#close_popup() :
      \ "\<C-y>"
    imap <expr><Cr>
      \ pumvisible() ?
      \   (neosnippet#expandable() ?
      \     "\<Plug>(neosnippet_expand)<Esc>gv" :
      \     (neosnippet#jumpable() ?
      \       "\<Plug>(neosnippet_jump)" :
      \       asyncomplete#close_popup())) :
      \ "\<Cr>\<Plug>DiscretionaryEnd"
    inoremap <expr><C-e> pumvisible() ? asyncomplete#cancel_popup() : "\<C-e>"
    imap <expr><C-k> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" :
      \ pumvisible() ? asyncomplete#close_popup() :
      \ "\<Del>"

    inoremap <expr><C-n> pumvisible() ? "\<C-n>" : asyncomplete#force_refresh()

    " Sort precessor in the document breaks triggering completion menu with different sources · Issue #162 · prabirshrestha/asyncomplete.vim
    " https://github.com/prabirshrestha/asyncomplete.vim/issues/162
    function! s:sort_by_priority_preprocessor(options, matches) abort
        let l:items = []
        let l:startcols = []
        for [l:source_name, l:matches] in items(a:matches)
            let l:startcol = l:matches['startcol']
            let l:base = a:options['typed'][l:startcol - 1:]
            for l:item in l:matches['items']
                if stridx(l:item['word'], l:base) == 0
                    let l:startcols += [l:startcol]
                    if l:source_name =~? '^asyncomplete_lsp_'
                      let l:item['priority'] = 999
                    else
                      let l:item['priority'] = get(asyncomplete#get_source_info(l:source_name), 'priority', 0)
                    endif
                    call add(l:items, l:item)
                endif
            endfor
        endfor

        let a:options['startcol'] = min(l:startcols)
        let l:items = sort(l:items, {a, b -> b['priority'] - a['priority']})

        call asyncomplete#preprocess_complete(a:options, l:items)
    endfunction

    let g:asyncomplete_preprocessor = [function('s:sort_by_priority_preprocessor')]

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('asyncomplete-buffer.vim') "{{{
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
    \ 'name': 'buffer',
    \ 'allowlist': ['*'],
    \ 'completor': function('asyncomplete#sources#buffer#completor'),
    \ 'config': {
    \    'max_buffer_size': 5000,
    \  },
    \ 'priority': 10,
    \ }))
endif "}}}
if Tap('asyncomplete-file.vim') "{{{
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#file#get_source_options({
    \ 'name': 'file',
    \ 'allowlist': ['*'],
    \ 'completor': function('asyncomplete#sources#file#completor'),
    \ 'priority': 10,
    \ }))
endif "}}}
if Tap('asyncomplete-emmet.vim') "{{{

  function! Asyncomplete_sources_emmet_completor(opt, ctx) abort
    let l:col = a:ctx['col']
    let l:typed = a:ctx['typed']

    let l:startcol = emmet#completeTag(1, '')
    if l:startcol < 0
      return
    elseif l:startcol > l:col
      let l:startcol = l:col
    endif
    let l:base = l:typed[l:startcol : l:col]
    let l:words = emmet#completeTag(0, l:base)
    let l:matches = map(l:words,'{"word":v:val,"dup":1,"icase":1,"menu": "[emmet]"}')
    call asyncomplete#complete(a:opt['name'], a:ctx, l:startcol + 1, l:matches)
  endfunction
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#emmet#get_source_options({
    \ 'name': 'emmet',
    \ 'allowlist': ['html'],
    \ 'completor': function('Asyncomplete_sources_emmet_completor'),
    \ 'priority': 5,
    \ }))
endif "}}}
if Tap('asyncomplete-neosnippet.vim') "{{{
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
    \ 'name': 'neosnippet',
    \ 'allowlist': ['*'],
    \ 'blocklist': ['html'],
    \ 'completor': function('asyncomplete#sources#neosnippet#completor'),
    \ 'priority': 1,
    \ }))
endif "}}}
if Tap('neco-syntax') "{{{
  let g:necosyntax#min_keyword_length=2
endif "}}}
if Tap('asyncomplete-necosyntax.vim') "{{{
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#necosyntax#get_source_options({
    \ 'name': 'necosyntax',
    \ 'allowlist': ['*'],
    \ 'completor': function('asyncomplete#sources#necosyntax#completor'),
    \ }))
endif "}}}
if Tap('neco-vim') "{{{
  let g:necovim#complete_functions = {
    \ 'Unite' : 'unite#complete_source',
    \ 'Ref' : 'ref#complete',
    \ 'Defx' : 'defx#util#complete',
    \ 'QuickRun' : 'quickrun#complete',
    \ 'Template' : 'sonictemplate#complete',
    \ 'PP' : 'var',
    \ 'PrettyPrint' : 'var',
    \ 'Capture' : 'command',
    \ }
endif "}}}
if Tap('asyncomplete-necovim.vim') "{{{
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#necovim#get_source_options({
    \ 'name': 'necovim',
    \ 'allowlist': ['vim'],
    \ 'completor': function('asyncomplete#sources#necovim#completor'),
    \ }))
endif "}}}
if Tap('asyncomplete-omni.vim') "{{{
  autocmd User asyncomplete_setup
    \ call asyncomplete#register_source(asyncomplete#sources#omni#get_source_options({
    \ 'name': 'omni',
    \ 'allowlist': ['*'],
    \ 'blocklist': ['c', 'cpp', 'ruby'],
    \ 'completor': function('asyncomplete#sources#omni#completor'),
    \ 'priority': 5,
    \  }))
endif "}}}
if Tap('vim-lsp') "{{{
  function! plugin.on_source() abort "{{{
    let g:lsp_use_lua = has('nvim-0.4.0') || (has('lua') && has('patch-8.2.0775'))
    let g:lsp_diagnostics_echo_cursor = 1
    let g:lsp_diagnostics_float_cursor = 1
    nmap [Plug]. <plug>(lsp-previous-diagnostic-nowrap)
    nmap [Plug], <plug>(lsp-next-diagnostic-nowrap)
    nmap <C-S-f> <plug>(lsp-document-format)
    vmap <C-S-f> <plug>(lsp-document-range-format)

    function! s:on_lsp_buffer_enabled() abort
      setlocal omnifunc=lsp#complete
      if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
      nmap <buffer> gd <plug>(lsp-definition)
      nmap <buffer> gs <plug>(lsp-document-symbol-search)
      nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
      nmap <buffer> gr <plug>(lsp-references)
      nmap <buffer> gi <plug>(lsp-implementation)
      " nmap <buffer> gt <plug>(lsp-type-definition)
      nmap <buffer> <leader>rn <plug>(lsp-rename)
      nmap <buffer> [g <Plug>(lsp-previous-diagnostic)
      nmap <buffer> ]g <Plug>(lsp-next-diagnostic)
      " nmap <buffer> K <plug>(lsp-hover)
    endfunction

    augroup lsp_install
      au!
      autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
    augroup END

  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    " call lsp#enable()
    function! LspStatusLine() abort "{{{
      let l:ret =''
      if !exists('*lsp#get_buffer_diagnostics_counts()')
        return l:ret
      endif
      let l:diagnostics = lsp#get_buffer_diagnostics_counts()
      let l:err_count = l:diagnostics["error"]
      if l:err_count > 0
        let l:ret.='%#Error#[E:'
        let l:ret.=l:err_count
        let l:ret.=']%*'
      endif
      let l:warn_count = l:diagnostics["warning"]
      if l:warn_count > 0
        let l:ret.='%#Todo[W:'
        let l:ret.=l:warn_count
        let l:ret.=']%*'
      endif
      let l:info_count = l:diagnostics["information"]
      if l:info_count > 0
        let l:ret.='[I:'
        let l:ret.=l:info_count
        let l:ret.=']'
      endif
      let l:hint_count = l:diagnostics["hint"]
      if l:hint_count > 0
        let l:ret.='[I:'
        let l:ret.=l:hint_count
        let l:ret.=']'
      endif
      return l:ret
    endfunction "}}}

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
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
  nnoremap <silent> [unite]m :<C-u>Unite -default-action=tabopen -buffer-name=files bookmark<CR>
  nnoremap <silent> [unite]D :<C-u>Unite -buffer-name=bookmark_directory bookmark:directory<CR>
  nnoremap <silent> [unite]h :<C-u>Unite -buffer-name=help help<CR>
  nnoremap <silent> [unite]H :<C-u>UniteWithCursorWord -immediately -buffer-name=help help<CR>
  nnoremap <silent><expr> [unite]s  ":\<C-u>:UniteWithInput -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line:all\<CR>"
  nnoremap <silent><expr> [unite]S  ":\<C-u>:UniteWithCursorWord -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line:all\<CR>"
  nnoremap <silent><expr> [unite]/  ":\<C-u>Unite -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line:all\<CR>"
  nnoremap <silent><expr> [unite]g/ ":\<C-u>Unite -max-multi-lines=1 -truncate -toggle -no-quit -buffer-name=search" . bufnr('%'). " line_migemo:all\<CR>"
  " nnoremap <silent> [unite]c :<C-u>Unite -buffer-name=bookmark -default-action=tabopen bookmark:default<CR>
  nnoremap <silent> [unite]d :<C-u>Unite bookmark:directory<CR>
  " nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>

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

  " autocmd MyAutoCmd QuickFixCmdPost [^l]* Unite -buffer-name=quickfix quickfix
  " autocmd MyAutoCmd QuickFixCmdPost [^l]* doautocmd FileType
  " autocmd MyAutoCmd QuickFixCmdPost l* exe 'Unite -profile-name=location_list -buffer-name=location_list' . bufnr('%'). ' location_list'
  " autocmd MyAutoCmd QuickFixCmdPost l* doautocmd FileType

  function! plugin.on_source() abort "{{{
    let g:unite_data_directory = expand(Getdir(g:vimrc_cache . '/unite', '$VIMFILES/tmp/.unite'))
    let g:unite_source_bookmark_directory = expand(Getdir(g:vimrc_data.'/unite_bookmark', '$VIMFILES/unite_bookmark'))

    let g:unite_enable_auto_select = 1

    let g:unite_split_rule = "botright"
    let g:unite_source_buffer_time_format = ''
    let g:unite_source_history_yank_enable = 1
    let g:unite_source_history_yank_limit = 5
    let g:unite_source_history_yank_save_clipboard = 0
    let g:unite_force_overwrite_statusline = 0

    call vimrc#util#set_default('g:unite_source_alias_aliases', {})
    let g:unite_source_alias_aliases.calc = 'kawaii-calc'
    let g:unite_source_alias_aliases.line_migemo = 'line'
    if g:is_windows
      let g:neossh#ssh_config = expand('$HOME/.ssh/config')
    endif

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

      nmap <buffer> i ggk<Plug>(unite_insert_enter)
      nmap <buffer> I ggk<Plug>(unite_insert_enter)
      nmap <buffer> A ggk<Plug>(unite_append_end)

    endfunction "}}}

  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    call unite#custom_default_action('file,bookmark', 'tabopen')
    call unite#custom_default_action('directory', 'lcd')
    call unite#custom_default_action('directory', 'lcd')
    call unite#custom_default_action('tag', 'vsplit')
    call unite#custom_default_action('command', 'execute')
    if has('migemo')
      call unite#custom_source('bookmark,buffer,menu,line_migemo,fold', 'matchers', 'matcher_migemo')
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

    "}}}

    "unite-menu"{{{
    call vimrc#util#set_default('g:unite_source_menu_menus', {})

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

    call s:readLauncher(s:c.command_candidates, '$VIMFILES/launcher/launcher.vim')
    if g:is_windows
      call s:readLauncher(s:c.command_candidates, '$VIMFILES/launcher/launcher_win.vim')
    endif
    call s:readLauncher(s:c.command_candidates, '$VIMFILES/launcher/launcher_local.vim')

    let g:unite_source_menu_menus["shortcut"] = deepcopy(s:c)
    unlet s:c
    "}}}

    "}}}

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('neoyank.vim') "{{{
  function! plugin.on_source() abort "{{{
    let g:neoyank#file = expand(Getdir(g:vimrc_cache . '/neoyank/history_yank', '$VIMFILES/tmp/.neoyank/history_yank'))
    let g:neoyank#limit = 30
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('unite-fold') "{{{
  function! plugin.on_source() abort "{{{
    let g:unite_fold_indent_space = ''
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('unite-everything') "{{{
  function! plugin.on_source() abort "{{{
    let g:unite_source_everything_full_path_search=1
    let g:unite_source_everything_ignore_pattern = '\.\%(git\|hg\|svn\)'
    let g:unite_source_everything_limit = 1000
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-hug-neovim-rpc') "{{{
  function! plugin.on_source() abort "{{{
    if has('python3')
      silent! py3 pass
    endif
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('mr.vim') "{{{
  function! plugin.on_source() abort "{{{
    let l:base_dir = expand(g:vimrc_cache).'/mr'
    let g:mr#mru#filename = l:base_dir.'/mru'
    let g:mr#mrw#filename = l:base_dir.'/mrw'
    let g:mr#mrr#filename = l:base_dir.'/mrr'

    let g:mr#mru#predicates = [{ filename -> filename !~# expand("$VIMBUNDLE/.cache") }]

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-precious') "{{{
  function! plugin.on_source() abort "{{{
    let g:precious_enable_switchers = {
      \ "*" : {
      \   "setfiletype" : 0
      \ },
      \ "html" : {
      \   "setfiletype" : 0
      \ },
      \ "javascript" : {
      \   "setfiletype" : 0
      \ },
      \ "css" : {
      \   "setfiletype" : 0
      \ },
      \ "vue" : {
      \   "setfiletype" : 0
      \ },
      \ "vim" : {
      \   "setfiletype" : 1
      \ },
      \}
    let g:precious_enable_switch_CursorMoved = {
      \   '*' : 0,
      \   'html' : 0,
      \   'xhtml' : 0,
      \   'markdown' : 1,
      \   'css' : 0,
      \   'javascript' : 0,
      \   'vim' : 1,
      \   'vue' : 0,
      \ }
    let g:precious_enable_switch_CursorMoved_i = g:precious_enable_switch_CursorMoved
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('context_filetype.vim') "{{{
  function! plugin.on_source() abort "{{{
    let g:context_filetype#search_offset = 300 "3000
    let g:context_filetype#filetypes = {
      \   'help': [],
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
      \   'vue': [
      \     { 'start' : '<template>',
      \       'end' : '</template>',
      \       'filetype' : 'vue.html', },
      \     { 'start' : '<script>',
      \       'end' : '</script>',
      \       'filetype' : 'vue.javascript', },
      \     { 'start' : '<style>',
      \       'end' : '</style>',
      \       'filetype' : 'vue.css', },
      \   ],
      \ }
    if !exists('g:context_filetype#same_filetypes')
      let g:context_filetype#same_filetypes = {}
    endif
    let g:context_filetype#same_filetypes.dosbatch = 'dos'

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('neosnippet') "{{{
  function! plugin.on_source() abort "{{{
    let g:neosnippet#disable_select_mode_mappings=1
    let g:neosnippet#snippets_directory = expand('$VIMFILES/snippets')
    let g:neosnippet_data_directory = expand(g:vimrc_cache . '/neosnippet')
    let g:neosnippet#data_directory = expand(g:vimrc_cache . '/neosnippet')
    let g:neosnippet#enable_snipmate_compatibility = 1
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    imap <C-s> <Plug>(neosnippet_start_unite_snippet)*
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('sonictemplate-vim') "{{{
  imap <c-t>t <C-o><plug>(sonictemplate)
  imap <c-t><c-t> <C-R>=unite#start_complete(['sonictemplate'], unite#get_profile('completion', 'context'))<Cr>
  function! plugin.on_source() abort "{{{
    " disabled default mapping.
    let g:sonictemplate_key = '<plug>(sonictemplate)'
    let g:sonictemplate_intelligent_key = '<plug>(sonictemplate-intelligent)'
    let g:sonictemplate_postfix_key = '<plug>(sonictemplate-postfix)'
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    " imap <c-t>t <plug>(sonictemplate)
    " imap <c-t><c-t> <plug>(sonictemplate)
    " imap <c-t>T <plug>(sonictemplate-intelligent)
    imap <c-t>t <plug>(sonictemplate)
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
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

  " closePopupしないで展開する
  imap <Plug>(emmet-expand-abbr-popup) <C-R>=emmet#expandAbbr(0,"")<CR>
  imap [emmet], <Plug>(emmet-expand-abbr-popup)
  imap <Plug>(emmet-expand-word-popup) <C-R>=emmet#expandAbbr(1,"")<CR>
  imap [emmet]; <Plug>(emmet-expand-word-popup)

  function! plugin.on_source() abort "{{{
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
  call Set_hook('hook_source', 'on_source')
endif "}}}

let s:installed_vim_ambicmd = Tap('vim-ambicmd')
if s:installed_vim_ambicmd "{{{
  cnoremap <expr> <Space> ambicmd#expand("\<Space>")
  cnoremap <expr> <CR>    ambicmd#expand("\<CR>")
endif "}}}
if Tap('lexima.vim') "{{{
  function! plugin.on_source() abort "{{{
    let g:lexima_enable_newline_rules = 0
    let g:lexima_enable_endwise_rules = 0 " <CR>のマッピングが上書きされるので無効化
    let g:lexima_map_escape = ''
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    call lexima#init()
    " https://snap.hyuki.net/20150712123156/
    call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '{', 'input': '{'})
    call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '(', 'input': '('})
    call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': '"', 'input': '"'})
    call lexima#add_rule({'at': '\%#.*[-0-9a-zA-Z_,:]', 'char': "'", 'input': "'"})
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}
if Tap('vim-endwise') "{{{
  function! plugin.on_source() abort "{{{
    let g:endwise_no_mappings = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}
if Tap('delimitmate') "{{{
  function! plugin.on_source() abort "{{{
    let g:delimitMate_excluded_ft = join(g:plugin_disable_filetypes, ',')
    autocmd MyAutoCmd Filetype markdown
      \  let b:delimitMate_expand_cr = 2
      \| let b:delimitMate_expand_inside_quotes = 1
      \| let b:delimitMate_expand_space = 0
      \| let b:delimitMate_nesting_quotes = ['`']
    autocmd MyAutoCmd Filetype dosbatch
      \  let b:delimitMate_matchpairs = substitute(&l:matchpairs, ',%:%', '', '')
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vfiler.vim') "{{{
  nmap <Leader>f [filer]
  nmap <Leader>F [filer]
  nnoremap [filer]? :<C-u>Mapping [filer]<CR>

  nnoremap <expr> [filer]f ':<C-u>VFiler -name=filerc-'.tabpagenr().' '.escape(expand('%:p:h'), ' ').'<CR>'
  nnoremap <expr> [filer]F ':<C-u>VFiler -name=filerb-'.tabpagenr().'<CR>'
  command! MemoExplorer execute 'VFiler -name=memo '.escape(g:memo_dir, ' ')
  nnoremap <F1> :<C-u>MemoExplorer<CR>

  function! plugin.on_source() abort "{{{
      " vimfilerの実装、defxのhelpを参考
    augroup vfiler-explorer
      autocmd!
      autocmd BufEnter,VimEnter,BufNew,BufWinEnter,BufRead,BufCreate *
        \ call s:vfiler_explorer(expand('<amatch>'))
    augroup END
    function! s:vfiler_explorer(path) abort
      let l:path = a:path
      if l:path == '' || bufnr('%') != expand('<abuf>')
        return
      endif
      " Disable netrw.
      if exists('#FileExplorer')
        autocmd! FileExplorer *
      endif

      if &filetype ==# 'vfiler' && line('$') != 1
        return
      endif

      " For ":edit ~".
      if fnamemodify(l:path, ':t') ==# '~'
        let l:path = '~'
      endif

      if isdirectory(expand(l:path))
        bwipeout
        execute 'VFiler ' . escape(expand(l:path), ' ')
      endif
    endfunction

  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
lua <<EOF
    require'vfiler/config'.clear_mappings()
    local action = require('vfiler/action')
    local myaction = require('vfiler/actions/myaction')
    require'vfiler/config'.setup {
      options = {
        auto_cd = false,
        auto_resize = true,
        columns = 'indent,icon,name',
        find_file = true,
        header = true,
        keep = true,
        listed = true,
        name = '',
        session = 'buffer',
        show_hidden_files = true,
        sort = 'name',
        layout = 'left',
        width = 30,
        height = 30,
        new = true,
        quit = true,
        toggle = true,
        row = 0,
        col = 0,
        blend = 0,
        border = 'rounded',
        zindex = 200,
        git = {
          enabled = false
        },
        preview = {
          layout = 'floating',
          width = 0,
          height = 0,
        },
      },

      mappings = {
        ['h'] = myaction.close_tree,
        ['j'] = action.loop_cursor_down,
        ['k'] = action.loop_cursor_up,
        ['l'] = myaction.open_by_choose_or_open_tree,
        ['gg'] = action.move_cursor_top,
        ['G'] = action.move_cursor_bottom,

        ['~'] = action.jump_to_home,
        ['\\'] = action.jump_to_root,
        ['J'] = action.jump_to_directory,
        ['L'] = action.switch_to_drive,

        ['.'] = action.toggle_show_hidden,
        ['<BS>'] = action.change_to_parent,
        ['<C-h>'] = action.change_to_parent,
        ['<C-l>'] = action.reload,
        ['<C-p>'] = action.toggle_auto_preview,
        ['<C-s>'] = action.toggle_sort,
        ['SO'] = action.change_sort,
        ['<CR>'] = action.open,
        ['e'] = action.open_by_vsplit,
        ['t'] = action.open_by_tabpage,
        ['v'] = action.open_by_vsplit,

        ['SS'] = function(vfiler, context, view)
          action.toggle_select(vfiler, context, view)
          action.move_cursor_up(vfiler, context, view)
        end,
        ['ss'] = function(vfiler, context, view)
          action.toggle_select(vfiler, context, view)
          action.move_cursor_down(vfiler, context, view)
        end,
        ['U'] = action.clear_selected_all,
        ['*'] = action.toggle_select_all,

        ['<C-r>'] = action.sync_with_current_filer,

        ['<Tab>'] = action.switch_to_filer,
        ['cc'] = action.copy_to_filer,
        ['mm'] = action.move_to_filer,

        ['yy'] = action.yank_path,
        ['YY'] = action.yank_name,

        -- ['b'] = action.list_bookmark,
        -- ['B'] = action.add_bookmark,

        ['p'] = action.toggle_preview,
        ['q'] = myaction.wipeout,
        ['Q'] = myaction.wipeout,

        ['x'] = action.execute_file,
        ['K'] = action.new_directory,
        ['r'] = action.rename,
        ['C'] = action.copy,
        ['dd'] = action.delete,
        ['D'] = action.delete,
        ['M'] = action.move,
        ['N'] = action.new_file,
        ['P'] = action.paste,

      },
    }
    require'vfiler/extensions/rename/config'.setup {
      options = {
        right = '1.0',
      },
    }
EOF
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('defx.nvim') "{{{

  " nmap <Leader>f [filer]
  " nmap <Leader>F [filer]
  " nnoremap [filer]? :<C-u>Mapping [filer]<CR>

  nnoremap <expr> [filer]e ':<C-u>Defx -buffer-name=explorer-'.tabpagenr().'<CR>'
  nnoremap <expr> [filer]E ':<C-u>Defx ' .escape(vimrc#get_project_directory(), ' :'). ' -buffer-name=project-'.tabpagenr().'<CR>'
  " nnoremap <expr> [filer]f ':<C-u>Defx ' .escape(expand('%:p:h'), ' :'). ' -search=' .escape(expand('%:p'), ' :'). ' -buffer-name=defx-'.tabpagenr().'<CR>'
  " nnoremap <expr> [filer]F ':<C-u>Defx -buffer-name=filer-'.tabpagenr().'<CR>'
  " command! MemoExplorer execute 'Defx -buffer-name=memo '.escape(g:memo_dir, ' :')
  " nnoremap <F1> :<C-u>MemoExplorer<CR>

  function! plugin.on_source() abort "{{{

    augroup defx-explorer
      autocmd!
      autocmd BufEnter * call s:browse_check(expand('<amatch>'))
    augroup END
    function! s:browse_check(path) abort
      " vimfilerの実装を参考
      if a:path == '' || bufnr('%') != expand('<abuf>')
        return
      endif
      " Disable netrw.
      if exists('#FileExplorer')
        autocmd! FileExplorer *
      endif

      let l:path = a:path
      " For ":edit ~".
      if fnamemodify(l:path, ':t') ==# '~'
        let l:path = '~'
      endif

      if &filetype ==# 'defx' && line('$') != 1
        return
      endif

      if isdirectory(expand(l:path))
        bwipeout
        execute 'Defx -split=no -new ' . escape(l:path, ' :')
      endif
    endfunction

    let g:defx_winwidth = 30
    let g:defx_explorer_columns = 'mark:indent:icon:filename'
    let g:defx_filer_columns = 'mark:indent:icon:filename:size:time'

    highlight Defx_filename_directory term=bold cterm=bold ctermfg=7 gui=bold guifg=SlateGray
    " highlight link Defx_icon_opened_icon PreProc
    highlight link Defx_mark_selected PreProc

    function! s:defx_cd(context) abort "{{{
      call inputsave()
      let l:cwd = input(a:context['root_marker'], a:context['cwd'], 'dir')
      if !empty(l:cwd)
        call defx#call_action('cd', [l:cwd])
      endif
      call inputrestore()
    endfunction "}}}
    function! s:defx_filter(context) abort "{{{
      let l:filter = get(b:, 'defx_filter', '')
      call inputsave()
      let l:filter = input('filter: ', l:filter)
      let b:defx_filter = l:filter
      call defx#call_action('change_filtered_files', [l:filter])
      call inputrestore()
    endfunction "}}}
    function! s:defx_toggle_safe_mode() abort "{{{
      let b:defx_safe_mode = (b:defx_safe_mode == v:true ? v:false : v:true)
    endfunction "}}}
    function! s:defx_is_safe_mode() abort "{{{
      if b:defx_safe_mode
        call vimrc#util#warn('In safe mode, this operation is disabled.')
      endif
      return b:defx_safe_mode
    endfunction "}}}

    function! DefxStatusLine() "{{{
      let l:ret =' '
      let l:ret.='%#StatusLineModeMsgVl#[%{b:defx["paths"][0]}]%*'
      let l:ret.='%#Error#%{b:defx_safe_mode?"":"[    ]"}%*'
      let l:ret.='%{b:defx_safe_mode?"[safe]":""}'
      let l:ret.='%#Search#%{get(b:, "defx_filter", "")}%*'
      let l:ret.='%<'
      let l:ret.='%='
      return l:ret
    endfunction "}}}
    function! s:defx_my_settings() abort "{{{

      let b:defx_safe_mode = v:true

      setl cursorline
      setl statusline=%!DefxStatusLine()

      nnoremap <silent><buffer><expr> <CR> defx#do_action('drop')
      nnoremap <silent><buffer><expr> e defx#do_action('open', 'choose')
      nnoremap <silent><buffer><expr> E defx#do_action('open', 'vsplit')
      nnoremap <silent><buffer><expr> P defx#do_action('preview')
      nnoremap <silent><buffer><expr> t defx#do_action('open', 'tabedit')

      nnoremap <silent><buffer><expr> j line('.') == line('$') ? '2gg' : 'j'
      nnoremap <silent><buffer><expr> k line('.') == 2 ? 'G' : 'k'

      nnoremap <silent><buffer><expr> ~ defx#do_action('cd')
      nnoremap <silent><buffer><expr> \\
        \ defx#do_action('cd', (g:is_windows ? [expand('%:p')[0:2]] : ['/']))
      nnoremap <silent><buffer><expr> i
        \ defx#do_action('call', g:vimrc_sid .'defx_cd')

      nnoremap <silent><buffer><expr> o
        \ defx#do_action('open_tree', 'toggle')
      nnoremap <silent><buffer><expr> O
        \ defx#do_action('open_tree', 'recursive:2')
      nnoremap <silent><buffer><expr> <BS> defx#do_action('cd', ['..'])
      nnoremap <silent><buffer><expr> <C-h> defx#do_action('cd', ['..'])
      nnoremap <silent><buffer><expr> l
        \ defx#is_directory() ?
        \   match(bufname('%'), 'filer') == -1 ?
        \     defx#do_action('open_tree') . 'j' :
        \     defx#do_action('open') :
        \ tabpagewinnr(tabpagenr(), '$') == 2 ?
        \   empty(bufname(winbufnr(2))) && !getbufvar(winbufnr(2), "&mod") ?
        \     defx#do_action('open', 'choose') :
        \     defx#do_action('open', 'vsplit') :
        \ defx#do_action('open', 'choose')
      nnoremap <silent><buffer><expr> h
        \ match(bufname('%'), 'filer') == -1 ?
        \ defx#do_action('close_tree') :
        \ defx#do_action('cd', ['..'])

      nnoremap <silent><buffer><expr> mm
        \ defx#do_action('call', g:vimrc_sid .'defx_filter')

      nnoremap <silent><buffer><expr> q defx#do_action('quit')
      nnoremap <silent><buffer> Q :<C-u>bwipeout<CR>

      nnoremap <silent><buffer><expr> cd defx#do_action('change_vim_cwd')
      nnoremap <silent><buffer><expr> gc defx#do_action('change_vim_cwd')

      nnoremap <silent><buffer><expr> gS <SID>defx_toggle_safe_mode()
      nnoremap <silent><buffer><expr> ss defx#do_action('toggle_select') . 'j'
      nnoremap <silent><buffer><expr> SS defx#do_action('toggle_select') . 'k'
      nnoremap <silent><buffer><expr> * defx#do_action('toggle_select_all')
      nnoremap <silent><buffer><expr> N
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('new_multiple_files')
      nnoremap <silent><buffer><expr> K
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('new_directory')
      nnoremap <silent><buffer><expr> cc
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('copy')
      vnoremap <silent><buffer><expr> cc
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('copy')
      nnoremap <silent><buffer><expr> mv
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('move')
      nnoremap <silent><buffer><expr> pp
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('paste')
      nnoremap <silent><buffer><expr> dd
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('remove_trash')
      nnoremap <silent><buffer><expr> DD
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('remove')
      nnoremap <silent><buffer><expr> r
        \ <SID>defx_is_safe_mode() ? '' : defx#do_action('rename')

      nnoremap <silent><buffer><expr> C
        \ match(bufname('%'), 'filer') == -1 ?
        \ defx#do_action('toggle_columns', g:defx_filer_columns) :
        \ defx#do_action('toggle_columns', g:defx_explorer_columns)
      nmap gs C
      nnoremap <silent><buffer><expr> S defx#do_action('toggle_sort', 'time')
      nnoremap <silent><buffer><expr> A
        \ winwidth(0) > g:defx_winwidth ?
        \ defx#do_action('resize', g:defx_winwidth) :
        \ defx#do_action('resize', 100)

      nnoremap <silent><buffer><expr> !\ defx#do_action('execute_command')
      nnoremap <silent><buffer><expr> x  defx#do_action('execute_system')
      nnoremap <silent><buffer><expr> yy defx#do_action('yank_path')
      nnoremap <silent><buffer><expr> .  defx#do_action('toggle_ignored_files')

      nnoremap <silent><buffer><expr> <C-l> defx#do_action('redraw')
      nnoremap <silent><buffer><expr> <C-g> defx#do_action('print')

      if exists(':Unite') is 2
        nnoremap <silent><buffer> ? :<C-u>Unite -buffer-name=mapping output:AllMaps\ <buffer><cr>
      else
        nnoremap <silent><buffer> ? :<C-U>map <buffer><CR>
      endif
    endfunction "}}}
    augroup defx-buffer-settings
      autocmd!
      autocmd FileType defx call s:defx_my_settings()
    augroup END

  endfunction "}}}
  function! plugin.on_post_source() abort "{{{

    call defx#custom#option('_', {
      \ 'listed': 1,
      \ 'resume': 1,
      \ 'toggle': 1,
      \ 'split': 'vertical',
      \ 'direction': 'topleft',
      \ 'winwidth': 30,
      \ 'vertical_preview': 1,
      \ 'preview_width': 50,
      \ 'columns': g:defx_explorer_columns,
      \ 'show_ignored_files': 1,
      \ 'root_marker': '[in]: ',
      \ })
    call defx#custom#option('filer', {
      \ 'split': 'no',
      \ 'columns': g:defx_filer_columns,
      \ })

    call defx#custom#column('mark', {
      \ 'length': 1,
      \ })
    call defx#custom#column('indent', {
      \ 'indent': '|'
      \ })
    call defx#custom#column('icon', {
      \ 'directory_icon': '+',
      \ 'opened_icon': '-',
      \ 'root_icon': '',
      \ })
    call defx#custom#column('filename', {
      \ 'root_marker_highlight': 'Special',
      \ })
    call defx#custom#column('time', {
      \ 'format': '%Y-%m-%d %H:%M:%S',
      \ })

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('which.vim') "{{{
  function! s:defWhichCommand() abort
    command! -nargs=1 Which echo Which(<q-args>)
  endfunction
  function! plugin.on_post_source() abort "{{{
    call s:defWhichCommand()
  endfunction "}}}
  call s:defWhichCommand()
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('capture.vim') "{{{
  function! plugin.on_source() abort "{{{
    let g:capture_open_command = 'vert new'
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
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
  function! plugin.on_source() abort "{{{
    let g:NERDMenuMode = 0 "Menu off
    let g:NERDCreateDefaultMappings = 0
    let g:NERDRemoveExtraSpaces = 1
    let g:NERDSpaceDelims = 1
    let g:NERDCustomDelimiters = {
      \   'dosbatch': {'left': 'REM', 'leftAlt': '::', 'right': '', 'rightAlt': ''},
      \   'sql' : {'left': '--', 'leftAlt': '/*', 'rightAlt': '*/', },
      \   'autohotkey' : {'left': ';', 'leftAlt': '/*', 'rightAlt': '*/'},
      \ }

    let g:ft = ''
    function! NERDCommenter_before() abort "{{{
      if &ft == 'vue'
        let g:ft = 'vue'
        let stack = synstack(line('.'), col('.'))
        if len(stack) > 0
          let syn = synIDattr((stack)[0], 'name')
          if len(syn) > 0
            exe 'setf ' . substitute(tolower(syn), '^vue_', '', '')
          endif
        endif
      endif
    endfunction "}}}
    function! NERDCommenter_after() abort "{{{
      if g:ft == 'vue'
        setf vue
        let g:ft = ''
      endif
    endfunction "}}}
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-rectinsert') "{{{
  nmap <silent> [Plug]P <Plug>(rectinsert_insert)
  vmap <silent> [Plug]P <Plug>(rectinsert_insert)
  nmap <silent> [Plug]p <Plug>(rectinsert_append)
  vmap <silent> [Plug]p <Plug>(rectinsert_append)
endif "}}}

if Tap('switch.vim') "{{{
  nnoremap [Plug]to :<C-u>Switch<CR>
  function! plugin.on_source() abort "{{{
    let g:switch_mapping = ""
    let g:switch_custom_definitions = [
      \   ['yes', 'no'],
      \   ['on', 'off'],
      \   ["月", '火', '水', '木', '金', '土', '日'],
      \   ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'],
      \   ['public', 'protected', 'private'],
      \ ]
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('gina.vim') "{{{
  function! plugin.on_source() abort "{{{
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    call gina#custom#execute('/.*',
      \ 'setlocal winfixheight foldcolumn=1 nofoldenable number')

    call gina#custom#mapping#nmap(
      \   '/.*', 'q',
      \   ':<C-u>q<CR>',
      \   {'noremap': 1, 'silent': 1}
      \ )

    function! s:ginalsSetting()
      nmap <buffer> gf <Plug>(gina-edit-tab)
      vmap <buffer> gf <Plug>(gina-edit-tab)
    endfunction
    function! s:ginastatusSetting()
      nnoremap <buffer> <Leader>wr :<C-U>Gina commit<CR>
    endfunction
    function! s:ginacommitSetting()
      nnoremap <buffer> <Leader>q :<C-U>q<CR>
    endfunction

    call gina#custom#command#alias('log', 'll')
    call gina#custom#command#alias('status', 'ss')
    call gina#custom#command#alias('branch', 'br')
    call gina#custom#command#alias('branch', 'switch')

    call gina#custom#command#option('/\v^%(ll|ss|br|switch|commit|diff|grep|ls|status|tag)',
      \ '--opener', 'vsplit')
    call gina#custom#command#option('/\v%(blame|compare|log|show|patch)',
      \ '--opener', 'tabedit')

    call gina#custom#command#option('ss', '-s')
    call gina#custom#command#option('ss', '-b')
    call gina#custom#command#option('commit', '-v|--verbose')

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('Align') "{{{
  function! plugin.on_source() abort "{{{
    let g:DrChipTopLvlMenu = ""
    let g:Align_xstrlen = 3
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-quickhl') "{{{
  nmap [Plug]h <Plug>(quickhl-manual-this)
  vmap [Plug]h <Plug>(quickhl-manual-this)
  nmap [Plug]H <Plug>(quickhl-manual-reset)
  vmap [Plug]H <Plug>(quickhl-manual-reset)
  nmap [Plug]j <Plug>(quickhl-cword-toggle)

  function! plugin.on_source() abort "{{{
    let g:quickhl_manual_hl_priority = 20
    let g:quickhl_manual_colors = []
    call add(g:quickhl_manual_colors, "gui=bold guifg=#ffffff guibg=#0a7383")
    call add(g:quickhl_manual_colors, "gui=bold guifg=#ffffff guibg=#a07040")
    call add(g:quickhl_manual_colors, "gui=bold guifg=#ffffff guibg=#4070a0")
    "To highlight some keyword always,
    "let g:quickhl_keywords = [ "TODO", "CAUTION", "ERROR" ]
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-textmanip') "{{{
  "mappings{{{
  nmap <M-Down> V<Plug>(textmanip-move-down)<Esc>
  nmap <M-Up> V<Plug>(textmanip-move-up)<Esc>
  nmap <M-Left> V<Plug>(textmanip-move-left)<Esc>
  nmap <M-Right> V<Plug>(textmanip-move-right)<Esc>

  xmap <M-Down> <Plug>(textmanip-move-down)
  xmap <M-Up> <Plug>(textmanip-move-up)
  xmap <M-Left> <Plug>(textmanip-move-left)
  xmap <M-Right> <Plug>(textmanip-move-right)
  "}}}
  function! plugin.on_source() abort "{{{
    let g:textmanip_enable_mappings = 0
    let g:textmanip_startup_mode='insert'
    let g:textmanip_current_mode='insert'
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-choosewin') "{{{
  map <LocalLeader>, <Plug>(choosewin)
  map <Leader>o <Plug>(choosewin)
  function! plugin.on_source() abort "{{{
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

    " Vimのquickfixとlocation listで好きな方法でファイルを開くプラグインを作った
    " https://zenn.dev/skanehira/articles/2021-10-28-vim-qfopen
    function! s:choosewin() abort
      let l:winid = win_getid()
      let l:wintype = win_gettype(l:winid)

      if l:wintype ==? "quickfix"
        let l:list = getqflist()
      elseif l:wintype ==? "loclist"
        let l:list = getloclist(l:winid)
      else
        return
      endif
      let l:info = l:list[line(".")-1]

      let l:result = choosewin#start(range(1,winnr('$')))
      " choosewin#start('noop')->win_getid()->win_gotoid()
      let l:opener = 'buffer'
      if empty(l:result)
        let l:opener = 'vsplit'
        " echo '#'->winnr()->win_getid()->win_gotoid()
        " call win_gotoid(win_getid(winnr('#')))
        execute "normal! \<C-w>p"
      endif
      execute l:opener bufname(l:info.bufnr)
      call cursor(l:info.lnum, l:info.col)
    endfunction

    augroup choosewin-qf
      autocmd!
      autocmd FileType qf nnoremap <buffer> a :<C-u>call <SID>choosewin()<CR>
    augroup END

  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-indent-guides') "{{{
  nmap [Plug]ig <Plug>IndentGuidesToggle
  function! plugin.on_source() abort "{{{
    let g:indent_guides_default_mapping = 0
    let g:indent_guides_enable_on_vim_startup=1
    let g:indent_guides_guide_size=0
    let g:indent_guides_indent_levels = 10
    let g:indent_guides_exclude_filetypes = g:plugin_disable_filetypes
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
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('number-marks') "{{{
  nmap mm <Plug>Place_sign
  nmap mn <Plug>Goto_next_sign
  nmap mp <Plug>Goto_prev_sign
  nmap md <Plug>Remove_all_signs
  nmap ma <Plug>Move_sign
  function! plugin.on_source() abort "{{{
    let g:number_marks_no_default_key_mappings = 1
    let g:Signs_file_path_corey = expand(g:vimrc_cache . '/number_marks')
    command! ThisSign exe 'sign place buffer=' . winbufnr(0)
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('colorizer') "{{{
  function! plugin.on_source() abort "{{{
    let g:colorizer_nomap = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-anzu') "{{{
  nmap n <Plug>(anzu-n-with-echo)
  nmap N <Plug>(anzu-N-with-echo)
  nmap * <Plug>(anzu-star)
  nmap # <Plug>(anzu-sharp)
  nmap g* g*<Plug>(anzu-update-search-status-with-echo)
  nmap g# g#<Plug>(anzu-update-search-status-with-echo)
  function! plugin.on_post_source() abort "{{{
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
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('vim-easymotion') "{{{
  map s <Plug>(easymotion-prefix)
  function! plugin.on_source() abort "{{{
    let g:EasyMotion_leader_key="s"
    let g:EasyMotion_grouping=2
    let g:EasyMotion_keys='jkhlasdfgyuiopqwertnmzxcvb'
    let g:EasyMotion_use_migemo = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('clever-f.vim') "{{{
  function! plugin.on_source() abort "{{{
    let g:clever_f_smart_case = 1
    let g:clever_f_use_migemo = 1

    let g:clever_f_mark_char = 1
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    map : <Plug>(clever-f-repeat-forward)
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('matchit.zip') "{{{
  function! plugin.on_post_source() abort "{{{
    silent! execute 'doautocmd Filetype ' &filetype
  endfunction "}}}
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('vim-milfeulle') "{{{
  nmap <C-o> <Plug>(milfeulle-prev)
  nmap <C-i> <Plug>(milfeulle-next)
  function! plugin.on_source() abort "{{{
    let g:milfeulle_default_jumper_name = 'win_tab_bufnr_pos_line'
    let g:milfeulle_default_kind = 'window'
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    nnoremap <silent> <Plug>(dzz) <C-d>zz
    nnoremap <silent> <Plug>(uzz) <C-u>zz
    nmap <C-d> <Plug>(milfeulle-overlay)<Plug>(dzz)
    nmap <C-u> <Plug>(milfeulle-overlay)<Plug>(uzz)
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('vim-textobj-fold') "{{{
  xmap az  <Plug>(textobj-fold-a)
  omap az  <Plug>(textobj-fold-a)
  xmap iz  <Plug>(textobj-fold-i)
  omap iz  <Plug>(textobj-fold-i)
  function! plugin.on_source() abort "{{{
    let g:textobj_fold_no_default_key_mappings = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
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
  function! plugin.on_source() abort "{{{
    let g:textobj_indent_no_default_key_mappings = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-textobj-multiblock') "{{{
  omap ab <Plug>(textobj-multiblock-a)
  omap ib <Plug>(textobj-multiblock-i)
  xmap ab <Plug>(textobj-multiblock-a)
  xmap ib <Plug>(textobj-multiblock-i)
  function! plugin.on_source() abort "{{{
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
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-textobj-between') "{{{
  omap af <Plug>(textobj-between-a)
  xmap af <Plug>(textobj-between-a)
  omap if <Plug>(textobj-between-i)
  xmap if <Plug>(textobj-between-i)
  function! plugin.on_source() abort "{{{
    let g:textobj_between_no_default_key_mappings=1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-operator-replace') "{{{
  map <LocalLeader>r <Plug>(operator-replace)
endif "}}}

if Tap('vim-operator-surround') "{{{
  map S  <Plug>(operator-surround-append)
  " map ds <Plug>(operator-surround-delete)
  map cs <Plug>(operator-surround-replace)
  vunmap cs
  vmap Cs <Plug>(operator-surround-replace)
endif "}}}

if Tap('vim-operator-convert-case') "{{{
  map <LocalLeader>tc <Plug>(operator-convert-case-toggle-upper-lower)
  map <LocalLeader>c <Plug>(operator-convert-case-loop)
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
  function! plugin.on_source() abort "{{{
    " 「日本語入力固定モード」の全バッファローカルモード
    let g:IM_CtrlBufLocalMode = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('win-ime-con.nvim') "{{{
  function! plugin.on_source() abort "{{{
    let g:win_ime_con_mode = 0
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-capslock') "{{{
  nmap [Plug]ca <Plug>CapsLockToggle
  imap [Plug]ca <C-o><Plug>CapsLockToggle
  cmap [Plug]ca <Plug>CapsLockToggle

  command! CapsLockToggle execute 'normal <Plug>CapsLockToggle'
  command! CapsLockEnable execute 'normal <Plug>CapsLockEnable'
  command! CapsLockDisable execute 'normal <Plug>CapsLockDisable'
  function! plugin.on_source() abort "{{{
    " exe printf('autocmd MyAutoCmd FileType %s CapsLockEnable',
    " \ join(g:capslock_filetype, ','))
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    " execute 'doautocmd Filetype ' &filetype
    autocmd! capslock InsertLeave
    autocmd! capslock CursorHold
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('vital.vim') "{{{
  function! VitalWrapper(...) "{{{
    if !exists('g:vital')
      call dein#source('vital.vim')
      let g:vital = vital#vital#new()
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

if Tap('calendar-vim') "{{{
  nmap <Leader>cal <Plug>CalendarV
  nmap <Leader>caL <Plug>CalendarH
  function! plugin.on_source() abort "{{{
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
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-quickrun') "{{{
  function! plugin.on_source() abort "{{{
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
    if get(g:, 'checkstyle_classpath', '') != '' && get(g:, 'checkstyle_xml', '') != ''
      let g:quickrun_config.checkstyle = {
        \   'exec': printf('java -cp "%s" com.puppycrawl.tools.checkstyle.Main -f plain -c "%s" "%%S" ', g:checkstyle_classpath, g:checkstyle_xml),
        \   'outputter': 'quickfix',
        \   'outputter/quickfix/errorformat': '%f:%l:%v:\ %m,%f:%l:\ %m,%-G%.%#',
        \   'outputter/quickfix/open_cmd': 'doautocmd QuickFixCmdPost quickrun',
        \   'hook/output_encode/encoding' : '&termencoding:&encoding',
        \ }
    endif
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
  function! plugin.on_post_source() abort "{{{
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
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('open-browser.vim') "{{{
  let g:openbrowser_no_default_menus = 1
  nmap gx <Plug>(openbrowser-open)
  vmap gx <Plug>(openbrowser-open)
endif "}}}

if Tap('vim-ruby') "{{{
  function! plugin.on_post_source() abort "{{{
    setlocal formatoptions-=r
    setlocal formatoptions-=o
  endfunction "}}}
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

"if Tap('css_color.vim') "{{{
"  function! plugin.on_post_source() abort "{{{
"    let &updatetime = g:update_time
"  endfunction "}}}
"endif "}}}

if Tap('java_fold') "{{{
  function! plugin.on_post_source() abort "{{{
    autocmd MyAutoCmd Filetype java setlocal foldmethod=expr foldexpr=GetJavaFold(v:lnum) foldtext=JavaFoldText()
  endfunction "}}}
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('previm') "{{{
  function! plugin.on_source() abort "{{{
    let g:previm_show_header=0
    let g:previm_enable_realtime=0
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}
if Tap('jedi-vim') "{{{
  function! plugin.on_source() abort "{{{
    py3 import os; sys.executable=os.path.join(sys.prefix, 'python.exe')
    let g:jedi#rename_command = '<Leader>rename'
    let g:jedi#usages_command = '<Leader>usage'
    let g:jedi#show_call_signatures = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-virtualenv') "{{{
  function! plugin.on_source() abort "{{{
    let g:virtualenv_directory = "."
    let g:virtualenv_stl_format = '[%n]'
  endfunction "}}}
  function! plugin.on_post_source() abort "{{{
    function! PyStatusline()
      return virtualenv#statusline() . MyStatusline()
    endfunction
    set statusline=%!PyStatusline()
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}
if Tap('vim-flake8') "{{{
  autocmd MyAutoCmd FileType python noremap <buffer> <F7> :call Flake8()<CR>
  function! plugin.on_source() abort "{{{
    let g:no_flake8_maps = 1
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
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
  function! plugin.on_source() abort "{{{
    function! s:qfreplaceSetting()
    endfunction
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

let g:migemodict = expand(printf('$VIMFILES/dict/migemo/%s/migemo-dict', &encoding))
if has('migemo')
  let &migemodict = g:migemodict
endif

if Tap('vim-migemo') "{{{
  if !has('migemo')
    nmap <silent> g/ <Plug>(migemo-migemosearch)
  endif
  function! plugin.on_post_source() abort "{{{
    call migemo#system('')
  endfunction "}}}
  call Set_hook('hook_post_source', 'on_post_source')
endif "}}}

if Tap('layoutplugin.vim') "{{{
  function! plugin.on_source() abort "{{{
    let g:layoutplugin#user_name = 'nakahiro386'
    let g:layoutplugin#plugins_contain_dir = expand('$VIMFILES/plugin')
  endfunction "}}}
  call Set_hook('hook_source', 'on_source')
endif "}}}

if Tap('vim-poweryank') "{{{
  map <Leader>y <Plug>(operator-poweryank-osc52)
  nmap <Leader>yy 0<Plug>(operator-poweryank-osc52)$
endif "}}}

if Tap('vim-oscyank') "{{{
  map <Leader>y <Plug>OSCYankOperator
  vmap <Leader>y <Plug>OSCYankVisual
  nmap <Leader>yy 0<Plug>OSCYankOperator$
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

call UnTap()

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
  if exists('*dein#check_install')
    function! s:switchEnabled(name) "{{{
      let l:catalog = expand('$VIM/switches/catalog/') . a:name
      let l:enabled = expand('$VIM/switches/enabled/') . a:name
      if !filereadable(l:enabled) && filereadable(l:catalog)
        call vimrc#file#copy(l:catalog, l:enabled)
      endif
    endfunction "}}}
    function! s:callSwitchEnabled() abort
      if !dein#check_install('vimdoc-ja')
        call s:switchEnabled('disable-vimdoc-ja.vim')
      endif
      if !dein#check_install('vimproc') && dein#get('vimproc').if
        call s:switchEnabled('disable-vimproc.vim')
      endif
      call s:switchEnabled('disable-go-extra.vim')
      delfunction s:switchEnabled
    endfunction
    augroup call-switch-enabled
      autocmd!
      autocmd CursorHold,CursorHoldI,FocusLost * call s:callSwitchEnabled()
        \| delfunction s:callSwitchEnabled
        \| exe 'autocmd! call-switch-enabled'
    augroup END
  endif

  function! s:writeVimrc_local(name, line) "{{{
    let s:vimrc_local = expand('$VIM/'.a:name)
    if !filereadable(s:vimrc_local)
      let s:ret = writefile(a:line, s:vimrc_local)
      if s:ret is -1
        call vimrc#util#error('write fails:' . s:vimrc_local)
      endif
      return s:ret
    endif
  endfunction "}}}
  call s:writeVimrc_local('vimrc_local.vim', ['let g:no_vimrc_example=1'])
  call s:writeVimrc_local('gvimrc_local.vim', ['let g:gvimrc_local_finish=1'])

  delfunction s:writeVimrc_local

endif
"}}}

"2html.vim"{{{
let g:html_dynamic_folds = 1
let g:html_no_foldcolumn = 0
let g:html_prevent_copy = "fntd"
"}}}

"}}}
"-----------------------------------------------------------------------------
"ColorScheme Highlight:"{{{

runtime colors/lists/csscolors.vim

let g:hlightHankakuSpaceLight = 'term=undercurl ctermbg=0 gui=underline guifg=grey70'
let g:hlightZenkakuSpaceLight = 'term=undercurl ctermbg=0 gui=underline guifg=Red guibg=grey90'

let g:hlightHankakuSpaceDark = 'term=undercurl ctermbg=0 gui=underline guifg=grey30 guibg=background'
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
  highlight DiffText guibg=darkRed
  highlight DiffAdd guibg=DarkBlue

  highlight TabLine     gui=underline guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  highlight TabLineFill gui=underline guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  "highlight TabLineInfo gui=underline guifg=fg guibg=NONE
  highlight TabLineInfo gui=underline,bold guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  "highlight TabLineNo gui=underline,bold guifg=Black guibg=lightgray ctermfg=fg ctermbg=bg
  highlight TabLineNo gui=underline,bold guifg=white guibg=DarkGreen ctermfg=15 ctermbg=28
  highlight TabLineSep  gui=underline guifg=fg guibg=NONE ctermfg=fg ctermbg=bg
  "highlight TabLineSel  gui=underline,reverse,bold guifg=Black guibg=grey80
  highlight TabLineSel  gui=underline,reverse guifg=fg guibg=NONE ctermfg=15 ctermbg=242
  "highlight link TabLineMod Error
  highlight TabLineMod gui=underline guifg=fg guibg=Red ctermfg=fg ctermbg=1

  highlight! default link StatusLineTerm StatusLine
  highlight! default link StatusLineTermNC StatusLineNC

  highlight StatusLineBufNum gui=bold guibg=bg
  highlight StatusLineMsg gui=bold guifg=red guibg=NONE
  highlight StatusLineModeMsg   term=bold ctermfg=10 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgNO term=bold ctermfg=10 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgIN term=bold ctermfg=9 gui=bold,reverse guifg=red
  highlight StatusLineModeMsgCL term=bold ctermfg=9 gui=bold,reverse guifg=red
  highlight StatusLineModeMsgRE term=bold ctermfg=10 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgRV term=bold ctermfg=10 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgVI term=bold ctermfg=14 gui=bold,reverse guifg=lightblue
  highlight StatusLineModeMsgVL term=bold ctermfg=14 gui=bold,reverse guifg=LightSkyBlue
  highlight StatusLineModeMsgVB term=bold ctermfg=14 gui=bold,reverse guifg=DodgerBlue
  highlight StatusLineModeMsgSE term=bold ctermfg=10 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgSB term=bold ctermfg=10 gui=bold,reverse guifg=green
  highlight StatusLineModeMsgTE term=bold ctermfg=9 gui=bold,reverse guifg=red
  highlight StatusLineModeMsgNT term=bold ctermfg=9 gui=bold,reverse guifg=red
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
  highlight NonText term=bold  ctermfg=15 ctermbg=0 guifg=cyan guibg=black
  highlight Cursor  guibg=#ffff99
  highlight Search ctermbg=215 guibg=peru guifg=wheat
  highlight clear  Visual
  highlight Visual gui=none guibg=grey30 ctermbg=59
  highlight LineNr ctermfg=210 guifg=lightred guibg=black
  highlight Pmenu      ctermfg=15 ctermbg=8 guifg=black guibg=#a6a190
  highlight PmenuSel   ctermfg=15 ctermbg=9 guifg=white guibg=#133293
  highlight PmenuSbar  ctermfg=0  ctermbg=0 guibg=#555555
  highlight PmenuThumb ctermfg=7  ctermbg=7 guibg=grey80
  highlight WildMenu   ctermfg=250 ctermbg=26 guifg=white guibg=#133293
  highlight Folded ctermfg=145 ctermbg=bg guifg=#c2bfa5
  highlight FoldColumn ctermfg=228 ctermbg=237
  highlight CursorLine term=underline guibg=#2b3b20
  highlight Type guifg=#5f7f3f
  highlight StatusLine ctermfg=bg ctermbg=187 guifg=gray20 guibg=#c2bfa5
  highlight StatusLineNC ctermfg=244 ctermbg=237 guibg=grey30
  highlight Comment guibg=grey10
  highlight Statement ctermfg=226 guibg=grey10
  highlight PreProc guibg=grey10
  highlight Type ctermfg=28 guibg=grey10
  highlight Identifier guibg=grey10
  highlight Constant guibg=grey10
  highlight Special guibg=grey10
  highlight ModeMsg guibg=grey10
  highlight MoreMsg guibg=grey10
  highlight WarningMsg guibg=grey10
  highlight Ignore guibg=grey10
  highlight Question guibg=grey10
  highlight SpecialKey guibg=grey10
  highlight Title guibg=grey10
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

augroup MyAutoCmd "{{{
  autocmd FileType * setlocal formatoptions-=r
    \| setlocal formatoptions-=o
    \| setlocal formatoptions+=mBj
  autocmd FileType * if exists("*s:".substitute(&filetype, '-', '', 'g').'Setting')
    \|  call s:{substitute(&filetype, '-', '', 'g')}Setting()
    \|endif
augroup END "}}}

"vim"{{{
"埋込言語のsyntax
let g:vimsyn_embed = 'Pr'
let g:vimsyn_folding = 0
"接続行のインデント数
let g:vim_indent_cont = &sw * 1
"}}}
"Ruby"{{{
"let ruby_no_expensive = 1 "endに対するブロック開始分にしたがった色付けを無効
let ruby_operators = 1 "演算子ハイライト
let ruby_space_errors = 1 "ホワイトスペースエラー
let ruby_fold = 1
let ruby_no_comment_fold = 1
"}}}
"python"{{{
let g:python_highlight_all = 1
"}}}
"java"{{{
let g:java_highlight_all=1
let g:java_highlight_debug=1
let g:java_space_errors=1
let g:java_highlight_java_lang_ids=1
let g:java_highlight_functions="style"
"let java_highlight_functions="indent"
let g:java_minlines = 30
"}}}
"xml{{{
  let g:xml_syntax_folding = 1
"}}}
"markdown{{{
let g:vim_markdown_folding_disabled = 1
"}}}

command! -nargs=? IndentSet call vimrc#set_indent(<args>)

augroup javap
  autocmd!
  autocmd BufReadPre,FileReadPre *.class setlocal binary
  autocmd BufReadPost,FileReadPost *.class call JavapCurrentBuffer()
augroup END

function! JavapCurrentBuffer() "{{{
  silent execute '%del _'

  let l:abs = vimrc#filepath#abspath(expand('%'))
  let l:path = vimrc#filepath#realpath(l:abs)
  if executable('java') && !empty(Which('cfr.jar'))
    let l:result = System(printf('java -jar "%s" "%s"', Which('cfr.jar'), l:path))
  elseif executable('jad')
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
" command! -nargs=* -complete=file E tabnew <args>
function! Enew(args) abort "{{{
  let l:args = a:args
  let l:prefix = 'file:///'
  let l:prefix_len = len(l:prefix)
  if l:prefix ==? l:args[0:(l:prefix_len - 1)]
    let l:args = l:args[(l:prefix_len):]
  endif
  execute 'tabnew ' . l:args
endfunction "}}}
command! -nargs=* -complete=file E call Enew(<q-args>)
command! -nargs=* -complete=file Enew call Enew(<q-args>)
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
noremap <silent> <Leader>vim  :<C-u>MYVIMRC<CR>:<C-u>CdCurrent<CR>
noremap <silent> <Leader>gvim :<C-u>MYGVIMRC<CR>:<C-u>CdCurrent<CR>
noremap <silent> <Leader>VIM  :<C-u>vsplit $MYVIMRC<CR>:<C-u>CdCurrent<CR>
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
function! s:LineCopy(mode, direction, count) abort "{{{
  if a:mode == 'n'
    let l:start = getpos('.')[1]
    let l:end = l:start
  elseif a:mode == 'V'
    let l:start = getpos("'<")[1]
    let l:end = getpos("'>")[1]
  endif
  let l:lines = getline(l:start, l:end)
  let l:lnum = a:direction == 'down' ? l:end : (l:start -1)
  for i in range(a:count)
    call append(l:lnum, l:lines)
  endfor
endfunction "}}}
nnoremap gy :<C-u>call <SID>LineCopy('n', 'down', v:count1)<CR>
xnoremap gy :<C-u>call <SID>LineCopy('V', 'down', v:count1)<CR>gv
nnoremap gY :<C-u>call <SID>LineCopy('n', 'up'  , v:count1)<CR>
xnoremap gY :<C-u>call <SID>LineCopy('V', 'up'  , v:count1)<CR>gv
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
    execute printf('noautocmd %s |doautocmd QuickFixCmdPre %s |doautocmd QuickFixCmdPost %s', l:cmd, l:fname, l:fname)
  endif
endfunction "}}}
command! -nargs=* -complete=file VimGrep
  \ call s:Grep('vimgrep /%s/gj %s', <f-args>)
command! -nargs=* -complete=file LVimGrep
  \ call s:Grep('lvimgrep /%s/gj %s', <f-args>)
command! -nargs=* -complete=file Grep call s:Grep('grep! %s %s', <f-args>)
command! -nargs=* -complete=file LGrep call s:Grep('lgrep! %s %s', <f-args>)

function! s:GitGrep(...) abort "{{{
  let l:cmd = 'grep! %s -e %s -- %s'
  let l:pattern = get(a:000, 0, '')
  let l:target = get(a:000, 1, '')
  let l:option = get(a:000, 2, '')

  call inputsave()
  if empty(l:pattern)
    let l:pattern = input('pattern : ' )
  endif
  if empty(l:target)
    let l:target = input('target : ', expand('%'.(g:is_windows ? ':p' : '')), "file")
  endif
  if empty(l:option)
    let l:option = input('option : ', '-I -i')
  endif
  call inputrestore()

  if !empty(l:pattern)
    let l:cmd = printf(l:cmd, l:option, l:pattern, l:target)
    let l:fname = matchstr(l:cmd, '\v^\w+')

    let l:bufnr = bufnr()
    let l:grepprg_ = &l:grepprg
    try
      let &l:grepprg = 'git grep -n'
      execute printf('noautocmd %s |doautocmd QuickFixCmdPre %s |doautocmd QuickFixCmdPost %s', l:cmd, l:fname, l:fname)
    finally
      call setbufvar(l:bufnr, '&grepprg', l:grepprg_)
    endtry

  endif
endfunction "}}}
command! -nargs=* -complete=file GitGrep call s:GitGrep(<f-args>)

function! s:GitLsfiles(...) abort "{{{
  let l:cmd = 'grep! %s -- %s'
  let l:pattern = get(a:000, 0, '')
  let l:option = get(a:000, 1, '')

  call inputsave()
  if empty(l:pattern)
    let l:pattern = input('pattern : ' )
  endif
  if empty(l:option)
    let l:option = input('option : ', '')
  endif
  call inputrestore()

  if !empty(l:pattern)
    let l:cmd = printf(l:cmd, l:option, l:pattern)
    let l:fname = matchstr(l:cmd, '\v^\w+')

    let l:bufnr = bufnr()
    let l:grepprg_ = &l:grepprg
    let l:grepformat_ = &l:grepformat
    try
      let &l:grepprg = 'git ls-files'
      let &l:grepformat = '%f'
      execute printf('noautocmd %s |doautocmd QuickFixCmdPre %s |doautocmd QuickFixCmdPost %s', l:cmd, l:fname, l:fname)
    finally
      call setbufvar(l:bufnr, '&grepprg', l:grepprg_)
      call setbufvar(l:bufnr, '&grepformat', l:grepformat_)
    endtry

  endif
endfunction "}}}
command! -nargs=* -complete=file GitLsfiles call s:GitLsfiles(<f-args>)

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
    call vimrc#util#warn(printf('buftype is [%s]. cannot toggle %s.', &buftype, a:option))
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
let g:sessionBaseDir = expand(Getdir(g:vimrc_data.'/session/', '$VIMFILES/tmp/session/'))
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
  function! s:session_select(info) abort closure "{{{
    let b:buffer_info = a:info
    setl buftype=nofile
    setl bufhidden=wipe
    setl nobuflisted
    setl nonumber
    setl nowrap
    setl cursorline
    setl nospell
    setl noswapfile
    setl foldcolumn=0
    if !a:info.newbuf
      setl modifiable
      setl noreadonly
      silent %d _
    endif
    let l:sessionDir = g:sessionBaseDir
    let l:lines = map(expand(g:sessionBaseDir.'*', 1, 1), 'fnamemodify(v:val, ":t")."|".fnamemodify(v:val, ":p")')
    call setline(1, l:lines)
    setl nomodifiable
    setl readonly

    let b:lastLnum = len(l:lines)
    let b:sessionFunc = {}
    function! b:sessionFunc.get_name() "{{{
      return split(getline("."), '|', 1)[0]
    endfunction "}}}
    function! b:sessionFunc.get_path() "{{{
      return split(getline("."), '|', 1)[1]
    endfunction "}}}
    function! b:sessionFunc.execute() "{{{
      let l:path = b:sessionFunc.get_path()
      exe tabpagenr('$').'tabnew'
      exe 'source '.l:path
      " exe 'bw! SessionSelect'
      exe 'tablast'
    endfunction "}}}
    function! b:sessionFunc.delete() "{{{
      let l:path = b:sessionFunc.get_path()
      call inputsave()
      let l:sessinFileName = input(l:path."\nAre you sure you want to remove file ? [y/n] : ")
      call inputrestore()
      let l:result = 0
      if l:sessinFileName == 'y'
        let l:result = delete(l:path)
        if l:result != 0
          call vimrc#util#error('delete fails : ' . l:path)
        endif
      endif
    endfunction "}}}

    nnoremap <buffer> <silent> <CR> :<C-u>call b:sessionFunc.execute()<CR>
    nnoremap <buffer> <silent> D :<C-u>call b:sessionFunc.delete()<CR>:call SessionSelect()<CR>
    nnoremap <buffer> <silent> yy :<C-u>let @*=b:sessionFunc.get_name()<CR>:echo 'yank!'<CR>
    nnoremap <buffer> <silent> Y :<C-u>let @*=b:sessionFunc.get_name()<CR>:echo 'yank!'<CR>
    nnoremap <buffer> <silent> p :<c-u>exe 'pedit ' matchstr(getline("."), "\|.*$")[1:]<cr>
    nnoremap <buffer> <silent> q :<C-U>call vimrc#buffer#close(b:buffer_info.bufname)<CR>
    nnoremap <buffer> <silent> Q :<C-U>call vimrc#buffer#wipeout(b:buffer_info.bufname)<CR>
    nnoremap <buffer> <silent> <C-r> :<C-u>call SessionSelect()<CR>
    nnoremap <buffer> <silent> <expr> j (line('.') is b:lastLnum ? 'gg' : 'j')
    nnoremap <buffer> <silent> <expr> k (line('.') is 1 ? 'G' : 'k')
    nnoremap <buffer> <silent> ? :<C-U>map <buffer><CR>
  endfunction "}}}
  let b:buffer_info = vimrc#buffer#open({'bufname': 'SessionSelect',
    \   'config': {'opener': '20vsplit'},
    \   'opened': function('s:session_select'),
    \ })

endfunction "}}}
function! s:Session(bang, session) abort "{{{
  let l:session = empty(a:session) ? g:sessionBaseDir . g:sessionDefaultName : a:session
  let l:session = expand(l:session)
  try
    if a:bang == '!'
      if filereadable(l:session)
        execute 'source '.l:session
      else
        call vimrc#util#warn(printf('file not readable [%s]', l:session))
      endif
    else
      execute 'mksession! '.l:session
    endif
  catch
    call vimrc#util#warn(v:throwpoint . "\n" . v:exception)
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
  let g:restore_vim_path = expand(Getdir(g:vimrc_cache, '$VIMFILES/tmp')) . '/restore.vim'
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

"sql-format"{{{
if executable('sql-formatter-cli')
  " npm i -g sql-formatter-cli

  function! s:SqlLineFormat(first,last) "{{{
    let l:cmd = 'sql-formatter-cli'
    let l:input = join(getline(a:first, a:last), "\n")
    let l:result = system(l:cmd, l:input)
    silent execute a:first . ',' . a:last . 'del _'
    execute string(a:first - 1) . 'put =l:result'
    redraw
  endfunction "}}}
  command! -range=% SqlLineFormat call s:SqlLineFormat(<line1>, <line2>)

  nnoremap <Leader>1 :SqlLineFormat<CR>
  vnoremap <Leader>1 :SqlLineFormat<CR>

endif
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
    return vimrc#process#system('nkf --'.l:system, a:input)
  endfunction
  "}}}
  command! Nkf echo system(printf('nkf -g "%s"', expand("%:p")))
  command! Nkfwin execute printf('!start nkfwin -g "%s"', IconvSystem(expand("%:p")))
endif
"}}}

"Vim-users.jp - Hack #203: 定義されているマッピングを調べる"{{{
"http://vim-jp.org/vim-users-jp/2011/02/27/Hack-203.html
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
      call vimrc#util#warn(v:exception)
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
nnoremap gC :<C-u>CdCurrent<CR>

function! s:CdProjectDirectory() abort "{{{
  let l:dir = vimrc#get_project_directory()
  let l:cd = exists(':tcd') is 2 ? 'tcd' : 'lcd'
  if !empty(l:dir)
    execute l:cd .' ' .l:dir
    verbose pwd
  endif
endfunction "}}}
command! -nargs=0 CdProjectDirectory call s:CdProjectDirectory()
nnoremap gc :<C-u>CdProjectDirectory<CR>

"SynCheck"{{{
function! s:SynCheck() "{{{
  for id in synstack(line("."), col("."))
    exe 'verbose hi '.synIDattr(id, "name")
    exe 'verbose hi '.synIDattr(synIDtrans(id), "name")
  endfor
endfunction "}}}
command! SynCheck call s:SynCheck()
"}}}

command! -bang -nargs=+ -complete=command Redir call vimrc#redir('<bang>',<q-args>)

"Vim-users.jp - Hack #84: バッファの表示設定を保存する"{{{
"https://vim-jp.org/vim-users-jp/2009/10/08/Hack-84.html
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
  return vimrc#file#open(join(a:000, ' '))
endfunction "}}}
"conversion"{{{
function! Outgoing(cmd)
  return s:iconv(a:cmd, &encoding, 'char')
endfunction
function! Incoming(cmd)
  return s:iconv(a:cmd, 'char', &encoding)
endfunction
function! s:iconv(expr, from, to)
  return vimrc#process#iconv(a:expr, a:from, a:to)
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
    call vimrc#util#error('"native2ascii" does not exist')
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
    call vimrc#util#error('"uniq" does not exist')
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

"tailread"{{{
"参考
"head.vim : ファイルの上か下、限定された行数のみを読み込む — 名無しのvim使い
"https://nanasi.jp/articles/vim/head_vim.html
"https://nanasi.jp/articles/code/sample/head.vim.html
command! -count=30 -bang -nargs=1 -complete=file TailRead call vimrc#tail(<f-args>, '<bang>', <count>)
if !exists('#Tail')
  augroup Tail
    autocmd!
    execute ":autocmd BufReadCmd   *;tail,*/*;tail TailRead <afile>"
    execute ":autocmd FileReadCmd  *;tail,*/*;tail TailRead <afile>"
  augroup END
endif
"}}}

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
  if g:_dein_is_installed
    nnoremap <Leader>RES :<C-u>call dein#clear_state()<Cr>:wviminfo!<Cr>:silent !start gvim<Cr>:qall<Cr>
  else
    nnoremap <Leader>RES :<C-u>wviminfo!<Cr>:silent !start gvim<Cr>:qall<Cr>
  endif
else
  nnoremap <Leader>res :<C-u>call vimrc#util#warn('not supported')<Cr>
  nnoremap <Leader>RES :<C-u>call vimrc#util#warn('not supported')<Cr>
endif

if has('terminal')
  if executable('bash')
    command! Bash terminal bash --login -i
  endif

  if g:is_windows
    command! Cmd terminal cmd.exe
    command! Powershell terminal powershell
    function! GitBash() abort
      let l:envs = '$VIM $VIMBUNDLE $VIMDICT $VIMFILES $VIMRUNTIME $MYVIMRC $MYGVIMRC'
      if g:is_msys
        let l:envs ..= ' $MSYSTEM'
      endif

      let l:guard = vimrc#util#store(split(l:envs))
      execute 'unlet ' .. l:envs
      let $MSYSTEM = 'MINGW64'

      let l:git_bash_path = ConvEnvPath("$ProgramFiles/Git/usr/bin/bash")
      call term_start(l:git_bash_path .. " --login -i")

      call l:guard.restore()
      if !g:is_msys
        unlet $MSYSTEM
      endif
    endfunction
    command! GitBash call GitBash()
  endif
endif

if g:inside_tmux
  command! TmuxNewWindow call system('tmux new-window')
  nnoremap <Leader>sh :<C-u>TmuxNewWindow<CR>
  command! TmuxVSplitWindow call system('tmux split-window -h')
  nnoremap <Leader>sv :<C-u>TmuxVSplitWindow<CR>
  command! TmuxSplitWindow call system('tmux split-window -v')
  nnoremap <Leader>ss :<C-u>TmuxSplitWindow<CR>
endif


let g:selector#action_keys = {
  \   'open': '<CR>',
  \   'tabopen': 't',
  \   'delete': 'dd',
  \   'preview': 'p',
  \   'split': 's',
  \   'vsplit': 'v',
  \   'quit': 'q',
  \   'wipeout': 'Q',
  \ }
let g:selector#config = {
  \   '_': {'opener': 'botright split'},
  \   'colorscheme': {'opener': 'botright 20vsplit'},
  \ }

nnoremap <silent> <Leader>bb :<C-u>Selector buffers<CR>
nnoremap <silent> <Leader>BB :<C-u>Selector! buffers<CR>
nnoremap <silent> <Leader>mm :<C-u>Selector mr<CR>
nnoremap <silent> <Leader>mu :<C-u>Selector mru<CR>
nnoremap <silent> <Leader>mw :<C-u>Selector mrw<CR>
nnoremap <silent> <Leader>mr :<C-u>Selector mrr<CR>
nnoremap <silent> <Leader>ua :<C-u>BookmarksAddCurrentFile<CR>
nnoremap <silent> <Leader>uc :<C-u>Selector bookmarks<CR>

" colorsel.vim
" https://gist.github.com/mattn/28009873b42dd2c1d62a
nnoremap <F9> :<C-u>Selector colorscheme<CR>

"}}}
"-----------------------------------------------------------------------------
"Finalization:"{{{
if has('vim_starting')
  call Source('$VIMRUNTIME/delmenu.vim')
  if argc()
    if g:_dein_is_installed
      call dein#call_hook('post_source')
    endif
  else
    if has('gui_running')
      cd $HOME
    endif
  endif
else
  if g:_dein_is_installed
    call dein#call_hook('source')
    call dein#call_hook('post_source')
  endif
endif

if has('nvim')
  call Source('$VIMFILES/init_local.vim', 1)
else
  call Source('$VIMFILES/.vimrc_local.vim', 1)
  call Source('$VIMFILES/vimrc_local.vim', 1)
endif

if len(g:messages) > 0
  augroup lazy-starting-msg
    autocmd!
    autocmd CursorHold,CursorHoldI,FocusLost * call map(g:messages, 'vimrc#util#error(v:val)')
      \| exe 'autocmd! lazy-starting-msg'
  augroup END
endif

"}}}
"-----------------------------------------------------------------------------
" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
