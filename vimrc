" Basic settings
set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set visualbell
set cursorline
set ttyfast
set ruler
set laststatus=2

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
set wildignore+=.git,.svn,current,svn,tmp*,node_modules,*.pyc

" Indentation - 4-column wide tabs, expand to 4 spaces for Python
set softtabstop=4
set tabstop=4
set shiftwidth=4
au FileType python set tabstop=4 shiftwidth=4 expandtab
au FileType puppet set softtabstop=2 tabstop=2 shiftwidth=2 expandtab
au FileType yaml set tabstop=4 shiftwidth=4 expandtab
au FileType php set tabstop=4 shiftwidth=4 expandtab
au FileType javascript set softtabstop=2 tabstop=2 shiftwidth=2
au FileType lua set softtabstop=2 tabstop=2 shiftwidth=2 expandtab
au FileType gitcommit set tw=72
autocmd BufNewFile,BufRead /usr/local/adnxs/maestro/* set tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab

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
nnoremap gp `[v`]
nnoremap <tab> %
vnoremap <tab> %
nnoremap ; $
vnoremap ; $

" Mappings for navigation between panes
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>
nmap <silent> <c-j><c-j> :close<CR>

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

" Map \f to refresh command-t file list
nnoremap <leader>f :CommandTFlush<cr>

" Map \c to open Conque terminal
nnoremap <leader>c :ConqueTerm bash<cr>
nnoremap <leader>cv :ConqueTermVSplit bash<cr>

" Map \y to copy buffer contents to clipboard
noremap <leader>y y :PBCopy<CR>

" Mlp \g to generate git url for current file
noremap <leader>g :Gitlink<CR>

" Turn on Pathogen
execute pathogen#infect()

" Setup syntastic
"pip install flake8
"pip install flake8-quotes
"pip install git+https://github.com/PyCQA/flake8-import-order.git@master
"let g:syntastic_python_checkers=['flake8']
let g:syntastic_python_checkers=['pyflakes']
let g:syntastic_javascript_checkers=['jsxhint']
let g:syntastic_javascript_jsxhint_exec = 'jsx-jshint-wrapper'
let g:syntastic_style_error_symbol='✠'
let g:syntastic_style_warning_symbol='≈'
let g:syntastic_error_symbol='✗'
let g:syntastic_warning_symbol='⚠'
let g:syntastic_auto_loc_list=1
let g:syntastic_loc_list_height=5
let g:syntastic_stl_format='[%E{Err: %fe (%e)}%B{|}%W{Warn: %fw (%w)}]'
let g:syntastic_mode_map={'mode': 'active',
  \ 'active_filetypes': ['javascript', 'php', 'python', 'vim'],
  \ 'passive_filetypes': ['puppet'] }

" Map \0 to reset syntastic
nnoremap <leader>0 :SyntasticReset<cr>

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
