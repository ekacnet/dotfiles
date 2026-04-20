" ALE / LSP / completion configuration.
" Keep navigation and diagnostics ownership here instead of spreading it across
" the main vimrc and helper files.

" Which folders to search for linter config files.
let s:lintrcfolders = ['.', expand('~')]

let s:gittop = systemlist('git rev-parse --show-toplevel')
if len(s:gittop) > 0 && s:gittop[0][0] ==# '/'
  call extend(s:lintrcfolders, [s:gittop[0]], 0)
endif

let s:lintrcpath = globpath(join(s:lintrcfolders, ','), '.pylintrc', 0, 1)
if len(s:lintrcpath) > 0
  let g:ale_python_pylint_options = '--rcfile=' . s:lintrcpath[0]
endif

let s:lintrcpath = globpath(join(s:lintrcfolders, ','), 'tox.ini', 0, 1)
if len(s:lintrcpath) == 0
  let s:lintrcpath = globpath(join(s:lintrcfolders, ','), '.tox.ini', 0, 1)
endif
if len(s:lintrcpath) > 0
  let g:ale_python_flake8_options = '--config ' . s:lintrcpath[0]
endif

" Keep ALE focused on linting/fixing and let vim-lsc own navigation.
let g:ale_linters_ignore = {
      \ 'cpp': ['cc'],
      \ 'c': ['cc'],
      \}
let g:ale_fix_on_save = 1
let g:ale_disable_lsp = 1
let g:ale_completion_delay = 300
let g:ale_go_gopls_options = '-remote=auto'

" External linters/fixers only. Avoid overlapping LSP-backed linters now that
" vim-lsc is the only navigation client.
let g:ale_fixers = {
      \ 'python': ['ruff', 'ruff_format'],
      \ 'go': ['goimports', 'gofmt'],
      \ 'bzl': ['buildifier'],
      \ 'terraform': ['terraform'],
      \ 'javascript': ['prettier'],
      \ 'typescript': ['prettier'],
      \}

let g:ale_linters = {
      \ 'go': ['govet'],
      \ 'python': ['ruff'],
      \ 'javascript': ['cspell', 'eslint', 'flow'],
      \}

" Use dispatch for ack/ag integration when available.
let g:ack_use_dispatch = 1

" Completion remains deoplete-based.
let g:deoplete#enable_at_startup = 1
" potentially change that to 0
let g:deoplete#enable_auto_select = 1
if exists('*deoplete#custom#option')
  call deoplete#custom#option('auto_complete_delay', 500)
  call deoplete#custom#option('auto_complete_start_length', 4)
endif

" vim-lsc owns definitions, references, implementations, hover, rename, code
" actions, and symbols. Keep the default maps and override the ones you already
" prefer.
let g:lsc_server_commands = {
 \  'sls': {
 \    'command': '/home/mat/bin/salt_lsp',
 \    'capabilities': ['completion'],
 \  },
 \  'typescript': {
 \    'command': 'typescript-language-server --stdio',
 \    'log_level': 2,
 \    'suppress_stderr': v:true,
 \  },
 \  'typescriptreact': {
 \    'command': 'typescript-language-server --stdio',
 \    'log_level': 2,
 \    'suppress_stderr': v:true,
 \  },
 \  'javascript': {
 \    'command': 'typescript-language-server --stdio',
 \    'log_level': 2,
 \    'suppress_stderr': v:true,
 \  },
 \  'python': {
 \    'name': 'pyright',
 \    'command': ['pyright-langserver', '--stdio'],
 \  },
 \  'cpp': {
 \    'command': '/usr/bin/ccls',
 \  },
 \  'c': {
 \    'command': '/usr/bin/ccls',
 \  },
 \  'go': {
 \    'command': ['gopls', '-remote=auto'],
 \    'log_level': -1,
 \    'suppress_stderr': v:true,
 \  },
 \}

let g:lsc_auto_map = {
 \  'defaults': v:true,
 \  'GoToDefinition': 'gd',
 \  'FindReferences': 'gr',
 \  'Rename': 'gR',
 \  'ShowHover': 'K',
 \  'FindCodeActions': 'ga',
 \  'Completion': 'omnifunc',
 \}
let g:lsc_default_map = v:true
let g:lsc_enable_autocomplete = v:true
let g:lsc_enable_diagnostics = v:false
let g:lsc_reference_highlights = v:false
let g:lsc_trace_level = 'off'

unlet s:gittop
unlet s:lintrcfolders
unlet s:lintrcpath
