let s:use_migemo = executable('cmigemo') && !empty(get(g:, 'migemodict', ''))
function! selector#open(name, bang) abort "{{{
  let l:name = a:name
  let l:bang = a:bang

  function! s:selector_opened(info) abort closure "{{{
    let b:_selector = {}
    let b:_selector['source_name'] = l:name
    let b:_selector['buffer_info'] = a:info
    let b:_selector['bang'] = l:bang
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
    call prompt_setcallback(l:bufnr, function('selector#_text_entered'))
    call selector#_text_entered(selector#_get_mask())
    startinsert!
    setl nomodified

    nnoremap <buffer><silent><nowait><expr> j (line('.') is line('$') ? 'gg' : 'j')
    nnoremap <buffer><silent><nowait><expr> k (line('.') is 1 ? 'G' : 'k')
    nmap <buffer><silent><nowait><expr> a (line('.') is line('$') ? 'a' : "\<Plug>(selector-action-choice)")

    let l:actions = keys(selector#action#get_default_actions()) + keys(selector#sources#get(l:name)["actions"])
    for l:action in l:actions
      execute printf(
            \ 'nnoremap <buffer><silent><nowait> <Plug>(selector-action-%s) :<C-u>call selector#action#call(b:_selector["source_name"], "%s")<CR>',
            \ l:action, l:action,
            \)

      let l:action_key = get(g:selector#action_keys, l:action, "")
      if !empty(l:action_key)
      execute printf(
            \ 'nmap <buffer><silent><nowait> %s <Plug>(selector-action-%s)',
            \ l:action_key, l:action,
            \)
      endif
    endfor

    call selector#modules#action#init()

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

func! selector#_text_entered(text) abort "{{{
  let b:_selector['mask'] = a:text
  if a:text == 'exit' || a:text == 'quit'
    stopinsert
    bwipeout
  else
    silent %d _
    call setline(1, 'mask: ' . a:text)
    let l:contents = selector#sources#get(b:_selector['source_name']).contents(b:_selector['bang'])
    if !empty(a:text)
      for l:t in split(a:text)
        if s:use_migemo
          let l:t = system(printf('cmigemo -v -w "%s" -d "%s"',l:t, g:migemodict))
        endif
        call filter(l:contents, 'v:val =~ l:t')
      endfor
    endif
    call setline(2, l:contents)
    silent execute "normal! i\<C-r>=selector#_get_mask()\<CR>"
    startinsert!
  endif
endfunction "}}}

func! selector#_get_mask() abort "{{{
  return get(b:_selector, 'mask', "")
endfunction "}}}

" vim:set filetype=vim expandtab shiftwidth=2 tabstop=2 foldmethod=marker:
