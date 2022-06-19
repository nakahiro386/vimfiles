scriptencoding utf-8
compiler xmllint
let &l:makeprg=&makeprg. ' %:p'
call vimrc#set_indent(2)
setlocal foldmethod=syntax
