" n = normal (ie. not in command, visual, select)
" i = insert mode
" c = command mode
" v = visual mode


" enable goyo + movement tzz
" zz: put current line at the center of the screen keep current column
nnoremap \W mt:Goyo<CR>'tzz
nnoremap \c :call TmuxPaneClear()<CR>

nnoremap \d :ALEToggleBuffer<CR>
nnoremap \f :ALEFix<CR>
" Invert number
nnoremap \n :setlocal number!<CR>:setlocal number?<CR>
" Invert paste mode !
nnoremap \o :set paste!<CR>:set paste?<CR>
" Invert number mode !
nnoremap \p :ProseMode<CR>
" allow to unhilight search
nnoremap \q :nohlsearch<CR>
" repeat the last command in the other tmux pane
nnoremap \r :call TmuxPaneRepeat()<CR>
" Enable spellchecker in the current buffer
nnoremap \s :setlocal invspell<CR>
" Invert the wrap mode and display the status in the command line
nnoremap \w :setlocal wrap!<CR>:setlocal wrap?<CR>
" Close quickfix window
nnoremap \x :cclose<CR>
" Useful on mac, save the file and call open on the filename of the current buffer (%)
nnoremap \z :w<CR>:!open %<CR><CR>

nnoremap <Leader>t :Files<CR>
nnoremap ; :Buffers<CR>
" Navigate more easily ALE ...
nnoremap <silent> ]aj :ALENext<cr>
nnoremap <silent> [ak :ALEPrevious<cr>

nnoremap <silent> ]om :call EnableMypyLinter()<CR>
nnoremap <silent> [om :call DisableMypyLinter()<CR>
" Codex shortcuts:
"   ,cc in normal mode opens an interactive Codex session in a split
"   ,cp prompts for an initial instruction before opening Codex
"   ,cc in visual mode asks for an instruction and sends the selected text
"   <ctrl-w>-c to close the window
nnoremap <silent> <leader>cc :Codex<CR>
nnoremap <silent> <leader>cp :call CodexPrompt()<CR>
xnoremap <silent> <leader>cc :<C-u>call CodexSendSelection('')<CR>

nnoremap <Leader>u :GundoToggle<CR>

" Turn off linewise keys. Normally, the `j' and `k' keys move the cursor down one entire line. with
" line wrapping on, this can cause the cursor to actually skip a few lines on the screen because
" it's moving from line N to line N+1 in the file. I want this to act more visually -- I want `down'
" to mean the next line on the screen
nmap j gj
nmap k gk

" Marks should go to the column, not just the line. Why isn't this the default?
nnoremap ' `

" Use ctrl + e to switch buffer
nnoremap <C-e> :e#<CR>

" Move between open buffers.
nnoremap <C-n> :bnext<CR>
nnoremap <C-p> :bprev<CR>

" Use the space key to toggle folds
nnoremap <space> za
vnoremap <space> zf

" Super fast window movement shortcuts
" Note this is combined with the remap bellow to give fast window movement AND keeping line and cols
nnoremap <C-j> <C-W>j
nnoremap <C-k> <C-W>k
nnoremap <C-h> <C-W>h
nnoremap <C-l> <C-W>l

" keep current line/col when switching left to right and vice versa
nnoremap <C-w>h :silent call KeepCurrentLine('h')<CR>
nnoremap <C-w>l :silent call KeepCurrentLine('l')<CR>

" Search for the word under the cursor in the current directory + create a [m]ark named [o] so that
" we can return to the original location, nb: we need to have a ":" to enter in command mode and
" type the function name (Ack, ...)
" ! to not jump to the first result, see make command documentation
" \b: word boundary end

"Prefer GGrep over Ggrep from vim-fugitive, also vim-fugitive is not dealing with \b markers
nnoremap <Esc>F   mo:GGrepw! "\b<cword>\b"<CR>
nnoremap <Esc>K   mo:Ggrepw!  "<cword>" <CR>

nnoremap <Esc>f   mo:Sack! "\b<cword>\b"<CR>
" Visual alternative of the above commands
"<C-U> remove the visual range
vnoremap <Esc>f   mo:<C-U>VAck!<CR>
vnoremap <Esc>F   mo:<C-U>VGGrep!<CR>

" Alt-W to delete a buffer and remove it from the list but keep the window via bufkill.vim
nnoremap <Esc>w :BD<CR>

" Quickly edit/reload the vimrc file
nnoremap <silent> <leader>ev :e $MYVIMRC<CR>
nnoremap <silent> <leader>sv :so $MYVIMRC<CR>

" Typing `$c` on the command line expands to the current path, so it's easy to edit a file in
" the same directory as the current file.
" Note: <C-\>e execute the function after it
cnoremap $c <C-\>eCurrentFileDir()<CR>

" in case you forgot to sudo, typing w!! in command mode will force the file to be written
" through sudo + tee
cnoremap w!! %!sudo tee > /dev/null %
