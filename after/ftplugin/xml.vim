scriptencoding utf-8
compiler xmllint
let &l:makeprg=&makeprg. ' %:p'
call IndentSet(2)
setlocal foldmethod=syntax
