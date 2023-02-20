function! selector#open(name, bang) abort "{{{
  let l:name = a:name
  let l:bang = a:name

  function! s:selector_opened(info) abort closure "{{{
    let b:_selector = {}
    let b:_selector['source_name'] = l:name
    let b:_selector['buffer_info'] = a:info
    let l:bufnr = a:info['bufnr']
    if a:info.newbuf
      autocmd InsertLeave,TextChangedI,TextChangedP <buffer> setl nomodified
    endif

    setl buftype=prompt
    setl bufhidden=hide
    setl filetype=selector
    setl nobuflisted
    setl number
    setl nowrap
    setl cursorline
    setl nospell
    setl noswapfile
    setl foldcolumn=0
    setl nomodified
    if !a:info.newbuf
      silent execute '%del _'
    endif
    call prompt_setprompt(l:bufnr, "> ")
    call prompt_setcallback(l:bufnr, function('s:text_entered'))
    call s:text_entered("")
    startinsert
    setl nomodified

    nnoremap <buffer><silent><expr> j (line('.') is line('$') ? 'gg' : 'j')
    nnoremap <buffer><silent><expr> k (line('.') is 1 ? 'G' : 'k')
    nmap <buffer><silent><expr> a (line('.') is line('$') ? 'a' : "\<Plug>(selector-action-choice)")

    let l:actions = keys(selector#action#get_default_actions()) + keys(selector#sources#get(l:name)["actions"])
    for l:action in l:actions
      execute printf(
            \ 'nnoremap <buffer><silent> <Plug>(selector-action-%s) :<C-u>call selector#action#call(b:_selector["source_name"], "%s")<CR>',
            \ l:action, l:action,
            \)

      let l:action_key = get(g:selector#action_keys, l:action, "")
      if !empty(l:action_key)
      execute printf(
            \ 'nmap <buffer><silent> %s <Plug>(selector-action-%s)',
            \ l:action_key, l:action,
            \)
      endif
    endfor

    call selector#modules#action#init()

  endfunction "}}}

  func! s:text_entered(text) abort closure "{{{
    let b:_selector['mask'] = a:text
    if a:text == 'exit' || a:text == 'quit'
      stopinsert
      bwipeout
    else
      silent %d _
      call setline(1, 'mask: ' . a:text)
      let l:contents = selector#sources#get(l:name).contents(a:bang)
      if !empty(a:text)
        let l:contents = filter(l:contents, 'v:val =~ a:text')
      endif
      call setline(2, l:contents)
    endif
  endfunction "}}}

  let l:selector_config = get(g:, 'selector#config', {})
  let l:base_config = get(l:selector_config, '_', {})
  let l:config = get(l:selector_config, l:name, {})
  let l:config = extendnew(l:base_config, l:config)
  let b:_selector['buffer_info'] = selector#buffer#open({
    \   'bufname': '[selector]'. l:name,
    \   'config': l:config,
    \   'opened': function('s:selector_opened'),
    \ })
endfunction "}}}
" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
