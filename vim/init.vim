" Turn on Pathogen
execute pathogen#infect()

" Neovim-only settings
if has('nvim')
  " Customize pymode plugin
  let g:pymode_python='python3'
  let g:pymode_options_max_line_length=100
  let g:pymode_breakpoint_bind='<leader>B'

  " Use only a subset of default pymode options
  let g:pymode_options=0
  setlocal complete+=t
  setlocal formatoptions-=t
  setlocal number
  setlocal commentstring=#%s
  setlocal define=^\s*\\(def\\\\|class\\)

  " Neovim Providers
  " TODO: Switch to $HOME once Neovim 0.3.2 released: https://github.com/neovim/neovim/issues/8778
  let g:ruby_host_prog='/Users/lwilliams/.rvm/gems/ruby-2.3.7/bin/neovim-ruby-host'
  let g:python_host_prog='/Users/lwilliams/.pyenv/versions/nvim-python/bin/python'
  let g:python3_host_prog='/Users/lwilliams/.pyenv/versions/nvim-python3/bin/python'
  let g:loaded_node_provider=1

  " Disable pymode linters in favor of Syntastic
  let g:pymode_lint=0

  " Point to lint executables within nvim python virtualenv
  let g:syntastic_yaml_yamllint_exec='$HOME/.pyenv/versions/nvim-python3/bin/yamllint'
  let g:syntastic_python_flake8_exec='$HOME/.pyenv/versions/nvim-python3/bin/flake8'
endif

" Basic settings
set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set novisualbell
set cursorline
set ttyfast
set ruler
set laststatus=2
set wrap
set number

" Keep an undo file to persist undo history across sessions
set undofile
set undodir=~/.vim/undodir
set undolevels=10000

" Disable file recovery / swapfiles
set nobackup
set noswapfile

" Tab-completion for filenames, ignore hidden/temp files
set wildmenu
set wildmode=list:longest,full
set wildignore+=.git,node_modules,*.pyc,htmlcov

" Supplement Command-T ignore list
let g:CommandTWildIgnore=&wildignore . ",*/data/build,*/codegen,*/vim/undodir"

" Map \f to refresh command-t file list
nnoremap <leader>f :CommandTFlush<cr>

" Remove ALL autocommands for the current group
autocmd!

" Indentation - 4-column wide tabs, expand to 4 spaces for specific file formats
set softtabstop=4
set tabstop=4
set shiftwidth=4
set expandtab
autocmd FileType python set tabstop=4 shiftwidth=4 expandtab
autocmd FileType puppet set softtabstop=2 tabstop=2 shiftwidth=2 expandtab
autocmd FileType yaml set tabstop=4 shiftwidth=4 expandtab
autocmd FileType php set tabstop=4 shiftwidth=4 expandtab
autocmd FileType javascript set softtabstop=2 tabstop=2 shiftwidth=2 expandtab
autocmd FileType lua set softtabstop=2 tabstop=2 shiftwidth=2 expandtab
autocmd FileType sh set tabstop=4 shiftwidth=4 expandtab
autocmd FileType gitcommit set tw=72

" Set text width indicator column
set textwidth=100
set formatoptions+=lro
set formatoptions-=tc
set colorcolumn=+1
highlight ColorColumn ctermbg=darkgrey

" Remove trailing whitespace for non-binary files on open/save
autocmd BufRead,BufWrite * if ! &bin | silent! %s/\s\+$//ge | endif

" Search settings - case-insensitive, search as-you-type, highlight matches
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
highlight search ctermfg=black ctermbg=yellow

" Make backspace work over auto-indentation and line breaks
set backspace+=indent,eol,start

" Map \p to toggle paste mode
set pastetoggle=<leader>p

" Enable syntax highlighting
syntax on
highlight comment ctermfg=green

" Mappings for navigation within buffer
nnoremap j gj
nnoremap k gk
inoremap jj <ESC>
cnoremap jj <ESC>
nnoremap gp `[v`]
nnoremap <tab> %
vnoremap <tab> %
nnoremap ; $
vnoremap ; $

" Map \e to opening and auto-loading this config file
map <leader>e :e! ~/.vimrc<cr>
autocmd! bufwritepost .vimrc source ~/.vimrc

" Map :w!! to allow writing file as sudo if opened normally
" http://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work?answertab=active#tab-top
cmap w!! w !sudo tee > /dev/null %

" Map \<space> to clearing highlights
nnoremap <leader><space> :noh<cr>

" Map \= to resize split panes to be equal
nnoremap <leader>= <c-w>=<cr>

" Map \\ to maximize current pane
nnoremap <leader><leader> <c-w>\|<cr>

" Map \b, \d, \n to list, close, and create new buffers
nnoremap <leader>b :buffers<cr>
nnoremap <leader>d :bp\|sp\|bn\|bd<cr>
nnoremap <leader>n :enew<cr>

" Map \y to copy buffer contents to clipboard
function! PBCopy()
  call system("pbcopy", getreg(""))
endfunction
noremap <leader>y y :call PBCopy()<CR>

" Map \g to generate git url for current file
"noremap <leader>g :Gitlink<CR>

" Disable tmux navigator when zooming the Vim pane
let g:tmux_navigator_disable_when_zoomed=1

" Write current buffer (if changed) before navigating from Vim to tmux pane
let g:tmux_navigator_save_on_switch=1

" Automatically set paste mode when pasting in insert mode
" https://github.com/ConradIrwin/vim-bracketed-paste
if !exists("g:bracketed_paste_tmux_wrap")
  let g:bracketed_paste_tmux_wrap = 1
endif

function! WrapForTmux(s)
  if !g:bracketed_paste_tmux_wrap || !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_ti .= WrapForTmux("\<Esc>[?2004h")
let &t_te .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin(ret)
  set pastetoggle=<f29>
  set paste
  return a:ret
endfunction

execute "set <f28>=\<Esc>[200~"
execute "set <f29>=\<Esc>[201~"
map <expr> <f28> XTermPasteBegin("i")
imap <expr> <f28> XTermPasteBegin("")
vmap <expr> <f28> XTermPasteBegin("c")
cmap <f28> <nop>
cmap <f29> <nop>

" Configure syntastic checkers
let g:syntastic_javascript_eslint_exec='eslint'
let g:syntastic_javascript_checkers=['eslint']
let g:syntastic_yaml_checkers=['yamllint']
let g:syntastic_python_checkers=['flake8']
let g:syntastic_mode_map={'mode': 'active',
\ 'active_filetypes': ['javascript', 'vim', 'ansible', 'python', 'yaml'] }

" Configure syntastic behavior
let g:syntastic_style_error_symbol='✠'
let g:syntastic_style_warning_symbol='≈'
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_auto_loc_list=1
let g:syntastic_always_populate_loc_list=1
let g:syntastic_loc_list_height=5
let g:syntastic_stl_format='[%E{Err: %fe (%e)}%B{|}%W{Warn: %fw (%w)}]'

" Map \0 to reset syntastic
nnoremap <leader>0 :SyntasticReset<cr>

" Set comment strings for common file types
autocmd FileType python setlocal commentstring=#\ %s
autocmd FileType sh setlocal commentstring=#\ %s
autocmd FileType vim setlocal commentstring=\"%s
autocmd FileType yaml setlocal commentstring=#\ %s
autocmd FileType dosini setlocal commentstring=#\ %s

" Customize vim-gitgutter plugin
set updatetime=200

" Customize status line
set statusline=%F\      "filename
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%y      "filetype
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file
