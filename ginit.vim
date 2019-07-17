let g:gvimrc_path = expand("<sfile>:p:h") . "/gvimrc"
" 互換性ないのでsourceｈあしない
let $MYGVIMRC = expand("<sfile>:p")

" see $VIM-qt/runtime/plugin/nvim_gui_shim.vim

" TODO 環境に応じて利用可能なフォントを設定するよう変更する
Guifont! MyricaM\ M:h12:cDEFAULT
GuiTabline 0
call GuiWindowMaximized(1)

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
