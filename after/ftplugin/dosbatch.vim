scriptencoding utf-8
let g:dosbatch_cmdextversion = 1
let b:match_words = '\<SETLOCAL\>:\<ENDLOCAL\>'
"let b:match_words .= ',%:%'

setlocal fileformat=dos
setlocal fileencoding=cp932
setlocal matchpairs+=%:%
setlocal dictionary+=$VIMDICT/dosbatch.dict
