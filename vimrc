set encoding=utf-8
set scrolloff=3
set autoindent
set showmode
set showcmd
set hidden
set wildmenu
set wildmode=list:longest
set visualbell
set cursorline
set ttyfast
set ruler
set laststatus=2
set undofile
set undodir=~/.vim/undodir
set undolevels=10000

set softtabstop=4
set tabstop=4
set shiftwidth=4

set ignorecase
set smartcase
set gdefault
set incsearch
set showmatch
set hlsearch
map <leader>e :e! ~/.vimrc<cr>
autocmd! bufwritepost .vimrc source ~/.vimrc
nnoremap <leader><space> :noh<cr>
nnoremap <leader>f :CommandTFlush<cr>
nnoremap <leader>b :buffers<cr>
nnoremap <leader>d :bp\|sp\|bn\|bd<cr>
nnoremap <leader>n :enew<cr>
nnoremap <leader>= <c-w>=<cr>
nnoremap <leader><leader> <c-w>\|<cr>
nnoremap <tab> %
vnoremap <tab> %
nnoremap ; $
vnoremap ; $

nnoremap j gj
nnoremap k gk
inoremap jj <ESC>
nnoremap gp `[v`]

nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>
nmap <silent> <c-j><c-j> :close<CR>

set backspace+=indent,eol,start
set wildignore+=.git,.svn,current,svn,tmp*
syntax on
highlight comment ctermfg=green

au FileType python set tabstop=4 shiftwidth=4 expandtab
