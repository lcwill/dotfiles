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

" Tab-completion for filenames, ignore hidden/temp files
set wildmenu
set wildmode=list:longest
set wildignore+=.git,.svn,current,svn,tmp*

" Indentation - 4-column wide tabs, expand to 4 spaces for Python
set softtabstop=4
set tabstop=4
set shiftwidth=4
au FileType python set tabstop=4 shiftwidth=4 expandtab

" Search settings - case-insensitive, search as-you-type, highlight matches
set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch

" Make backspace work over auto-indentation and line breaks
set backspace+=indent,eol,start

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

