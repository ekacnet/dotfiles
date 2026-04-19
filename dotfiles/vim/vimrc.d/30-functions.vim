" Functions
" ! to override
function! GetVisualSelection(delim)
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    return join(lines, a:delim)
endfunction

function! VGGrepfunc(bang)
  let words = GetVisualSelection(" ")
  let words = substitute(words, '\([().[\]]\)', '\\\1',"g")
  if len(words) > 2
    call GGrep(a:bang, words)
  endif
endfunction

function! VAckfunc(cmd)
  let words = GetVisualSelection(" ")
  let words = substitute(words, '\([().[\]]\)', '\\\1',"g")
  if len(words) > 2
    call ack#Ack(a:cmd, '"'.words.'"')
  endif
endfunction

" "Safe" version of Ack! that don't run even if it's just a quote or a semicolon
function! Sackfunc(cmd, args)
  " we usually call this function with "\b<real_term>\b" so there is at least 6
  " chars no matter what let's trigger a search only if we have more than 3 letters
  if len(a:args) > 9
    call ack#Ack(a:cmd, a:args)
  endif
endfunction

function! ProseMode()
  call goyo#execute(0, [])
  set spell noci nosi noai nolist noshowmode noshowcmd
  set complete+=s
  set bg=light
  hi SpellBad ctermfg=1 term=bold ctermbg=225 gui=undercurl guisp=Magenta

  if !has('gui_running')
    let g:solarized_termcolors=256
  endif

  call deoplete#disable()
  "colors solarized
endfunction

" Codex helpers:
"   :Codex opens Codex in a terminal split rooted at the current working directory
"   :Codex write a regression test for this file
"   visually select text, then run :CodexSelection refactor this piece
let s:codex_bufnr = -1

function! s:CodexBufferUsable() abort
  if s:codex_bufnr <= 0 || !bufexists(s:codex_bufnr)
    return 0
  endif

  if getbufvar(s:codex_bufnr, '&buftype') !=# 'terminal'
    return 0
  endif

  if exists('*term_getjob') && exists('*job_status')
    let l:job = term_getjob(s:codex_bufnr)
    if type(l:job) != v:t_job || job_status(l:job) !=# 'run'
      return 0
    endif
  endif

  return 1
endfunction

function! s:CodexPrepareWindow() abort
  if s:CodexBufferUsable()
    let l:winnr = bufwinnr(s:codex_bufnr)
    if l:winnr > 0
      execute l:winnr . 'wincmd w'
    else
      botright 15split
      execute 'buffer ' . s:codex_bufnr
    endif
    return
  endif

  let s:codex_bufnr = -1
  botright 15split
endfunction

function! CodexOpen(prompt) abort
  let l:cmd = ['codex', '--cd', getcwd()]
  if !empty(a:prompt)
    call add(l:cmd, a:prompt)
  endif

  if exists('*term_start')
    if s:CodexBufferUsable()
      call s:CodexPrepareWindow()
    else
      call s:CodexPrepareWindow()
      call term_start(l:cmd, {'curwin': 1, 'term_finish': 'open'})
      let s:codex_bufnr = bufnr('%')
    endif
    startinsert
  elseif exists(':terminal')
    if s:CodexBufferUsable()
      call s:CodexPrepareWindow()
    else
      call s:CodexPrepareWindow()
      execute 'terminal ++curwin ' . join(map(copy(l:cmd), 'shellescape(v:val)'), ' ')
      let s:codex_bufnr = bufnr('%')
    endif
    startinsert
  else
    echoerr 'Codex integration requires Vim with +terminal support'
  endif
endfunction

function! CodexPrompt() abort
  let l:prompt = input('Codex prompt: ')
  if empty(trim(l:prompt))
    echo 'Codex prompt cancelled'
    return
  endif

  call CodexOpen(l:prompt)
endfunction

function! CodexSendSelection(instruction) abort
  let l:selection = GetVisualSelection("\n")
  if empty(trim(l:selection))
    echoerr 'No visual selection found'
    return
  endif

  let l:instruction = a:instruction
  if empty(trim(l:instruction))
    let l:instruction = input('Codex prompt: ')
  endif
  if empty(trim(l:instruction))
    echo 'Codex prompt cancelled'
    return
  endif

  let l:filetype = empty(&filetype) ? 'text' : &filetype
  let l:filename = expand('%:p')
  let l:context = empty(l:filename) ? '' : ' from ' . l:filename
  let l:prompt = l:instruction . "\n\nSelected text" . l:context . ":\n```" . l:filetype . "\n" . l:selection . "\n```"
  call CodexOpen(l:prompt)
endfunction

function! s:isdictionary(x)
  return type(a:x) == v:t_dict
endfunction

function! DisableMypyLinter()
  let l:linters = get(b:, 'ale_linters', [])
  if s:isdictionary(l:linters)
    if has_key(b:ale_linters, 'mypy')
      b:ale_linters['mypy'] = {}
    endif
  endif
endfunction

function! EnableMypyLinter()
  let l:linters = get(b:, 'ale_linters', [])
  if !s:isdictionary(l:linters)
    let b:ale_linters = {
    \  'python' : g:ale_linters['python']
    \  }
  endif

  if !has_key(b:ale_linters, 'python')
    call add(b:ale_linters['python'], 'mypy')
  endif
endfunction

" Commands to send common keystrokes using tmux
" +1 aka next pane
let g:tmux_console_pane = '+1'
let g:tmux_server_pane = '+1'

function! TmuxPaneRepeat()
  write
  silent execute '!tmux send-keys -t ' . shellescape(g:tmux_console_pane) . ' Up C-j'
  redraw!
endfunction

function! TmuxPaneClear()
  silent execute '!tmux send-keys -t ' . shellescape(g:tmux_server_pane) . ' C-l'
  redraw!
endfunction

" Make the cursor stay on the same line when window switching
function! KeepCurrentLine(motion)
  let theLine = line('.')
  let theCol = col('.')
  exec 'wincmd ' . a:motion
  if &diff
    call cursor(theLine, theCol)
  endif
endfunction

" expand %, # and < based special characters
" needed when you don't call some function like grep and what not that will do the translation
function! ExpandString(string)
  let str = a:string
  for c in ["%", "#", "<"]
    if c == "%"
      let str = substitute(str, "%", expand("%"), "g")
    endif
    if c == "#"
      let str = substitute(str, '\(#\d*\)', '\=expand(submatch(1))', "g")
    endif
    if c == "<"
      let str = substitute(str, '\(<.*>\)', '\=expand(submatch(1))', "g")
    endif
  endfor
  return str
endfunction

" Can't call directly GGrep with things like <cword> or \b<cword>\b as they are not extrapolated
" the goal of this function is extrapolate/expand them as it would happen with the vim grep command
function! GGrepwrapper(bang, words)
  if empty(a:words)
    let words = [expand("<cword>")]
  else
    let words = []
    for w in a:words
      let words = add(words, ExpandString(w))
    endfor
  endif
  " Note because we have both the function and the command, calling without the call will call the
  " command not the function and the parameters are not expanded but passed as is
  "Also not passing bang to GGrep because I don't want it full screen
  call GGrep("", words)
endfunction

function! GGrep(bang, words)
  if a:bang == "!"
    let fullscreen = 1
  else
    let fullscreen = 0
  endif
  " Leverage fzf to do Git Grep
  " - The second argument to `fzf#vim#grep` is 0 (false), because `git grep` does
  " not print column numbers.
  " - We set the base directory to git root by setting `dir` attribute in spec
  " dictionary.

  " <bang> when calling function will translate to the ! char, so if included in a
  " string it will be concatenated, for instance foo<bang> will give foo!, if it's a integer
  " then it will negate it's value ie. <bang>0 becomes !0 or 1 if the command was called with bang
  " iterate on a:words and shellescape them
  let words_list = []
  for w in a:words
    if !(w =~ '^"' || w =~"^'" || w =~ '"$' || w =~ "'$")
      let w = shellescape(w)
    endif
    let words_list = add(words_list, w)
    let words = join(words_list, ' ')
  endfor

  call fzf#vim#grep('git grep --line-number -- '.words, 0,  fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), fullscreen)
endfunction

function! CommitMessages()
    nmap S iSigned-off-by: Matthieu Patou <mat@matws.net><CR><ESC>
    nmap R iReviewed-by: Matthieu Patou <mat@matws.net><CR><ESC>
    " abreviation that works in insert mode
    iab #S Signed-off-by: Matthieu Patou <mat@matws.net>
    iab #R Reviewed-by: Matthieu Patou <mat@matws.net>
    iab #O Signed-off-by:
    iab #V Reviewed-by:
    iab #P Pair-Programmed-With:
    iab `` ```<CR><CR>```
    " Go to the first line of the commit message
    exe ":1"
endf

" Fallback to yaml if a sls file is not detected as python or sls
function! FallbackSalt()
  let fts = ['sls', 'python']
  if index(fts, &filetype) == -1
    set ft=yaml
  endif
endfunction
