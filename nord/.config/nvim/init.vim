" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝

let mapleader ="\<Space>"

" Behavior
syntax on
syntax enable

filetype on
filetype plugin on
filetype indent on

set ttimeoutlen=0
set updatetime=300
set splitbelow splitright
set conceallevel=2

set autoindent
set smartindent
set cindent
set cinoptions=g0,:0,N-s,(0

set expandtab
set foldmethod=indent
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab

set wrap linebreak nolist
set shortmess+=c
set whichwrap+=<,>,h,l
set virtualedit=block,onemore
set backspace=2
set sidescroll=10

set hlsearch
set incsearch
set ignorecase
set smartcase

set autoread
set autowrite
set noswapfile
set nobackup
set nowritebackup
set undodir=~/.nvim/undodir
set undofile
nnoremap c "_c

set nocompatible
set langmenu=zh_CN.UTF-8
set helplang=cn
set termencoding=utf-8
set encoding=utf8
set fileencodings=utf8,ucs-bom,gbk,cp936,gb2312,gb18030

" vim-interface
set t_Co=256
if has('termguicolors')
    set termguicolors
endif
set noeb
set mouse=a
set hidden
set showcmd
set ruler
set cursorline
set cursorcolumn
set number relativenumber
set cmdheight=2
set laststatus=2
set showtabline=2
set noshowmode
set nohlsearch
set nofoldenable
let g:webdevicons_enable_startify = 1

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("patch-8.1.1564")
  set signcolumn=number
else
  set signcolumn=yes
endif

" Command Completion
set wildmenu
set wildmode=longest:full,full
set completeopt-=preview

" Vim-Plug init
if ! filereadable(expand('~/.config/nvim/autoload/plug.vim'))
	echo "Downloading junegunn/vim-plug to manage plugins..."
	silent !mkdir -p ~/.config/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ~/.config/nvim/autoload/plug.vim
endif

" Vim-Plug Plugins

call plug#begin('~/.config/nvim/plugged')

Plug 'rakr/vim-one'
Plug 'arcticicestudio/nord-vim'
Plug 'b4skyx/serenade'
Plug 'ryanoasis/vim-devicons'

Plug 'kassio/neoterm'
Plug 'mhinz/vim-startify'
Plug 'godlygeek/tabular'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'mbbill/undotree'

Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'

Plug 'rbgrouleff/bclose.vim'
Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
Plug 'junegunn/goyo.vim'

Plug 'jreybert/vimagit'
Plug 'airblade/vim-gitgutter'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'thinca/vim-quickrun'
Plug 'pechorin/any-jump.vim'
Plug 'sheerun/vim-polyglot'

Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'

Plug 'ap/vim-css-color'
Plug 'iamcco/markdown-preview.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'easymotion/vim-easymotion'
Plug 'rhysd/accelerated-jk'

call plug#end()

" Edit Setting
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif

augroup RELOAD
	autocmd!
	" Close vim when Nerdtree is last window
	autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

	" Disables automatic commenting on newline:
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

	" Automatically deletes all trailing whitespace on save.
	autocmd BufWritePre * %s/\s\+$//e
augroup END

" Init.vim Setting
    nnoremap <leader><leader>v :tabe $MYVIMRC<cr>
	nnoremap <leader><leader>s :source $MYVIMRC<cr>

" Plug Setting
	nnoremap <leader><leader>i :PlugInstall<cr>
	nnoremap <leader><leader>u :PlugUpdate<cr>
	nnoremap <leader><leader>c :PlugClean<cr>

" Common Settings
    nnoremap <A-r> :@:<cr>

" Clipboard
	set go=a
	set clipboard+=unnamedplus

" Clipboard Remap
	vnoremap <leader>y  "+y
	nnoremap <leader>Y  "+yg_
	nnoremap <leader>y  "+y
	nnoremap <leader>yy  "+yy
	nnoremap <leader>p "+p
	nnoremap <leader>P "+P
	vnoremap <leader>p "+p
	vnoremap <leader>P "+P

" TagBar
	nmap <leader>t :TagbarToggle<cr>

" Spell-check set to <leader>o, 'o' for 'orthography':
	nmap <leader>o :setlocal spell! spelllang=en_us<cr>

" Split Navigation shortcuts
	noremap <leader>wv :vsplit<cr>
	noremap <leader>ws :split<cr>
	noremap <C-h> <C-w>h
	noremap <C-j> <C-w>j
	noremap <C-k> <C-w>k
	noremap <C-l> <C-w>l

" Buffer Navigation
	noremap <A-j> :bn<cr>
	noremap <A-k> :bp<cr>
    noremap <A-q> :bw<cr>
    noremap <A-S-q> :bw!<cr>

" Curor Navigation
    map <leader><leader>w <Plug>(easymotion-w)
    map <leader>f <Plug>(easymotion-bd-f)
    nmap <leader>f <Plug>(easymotion-overwin-f)
" Keep selection after shift
    vnoremap < <gv
    vnoremap > >gv

" Replace all is aliased to S.
	nnoremap S :%s//g<Left><Left>

" Accelerated J/K
    nmap j <Plug>(accelerated_jk_gj)
    nmap k <Plug>(accelerated_jk_gk)

" Goyo
	noremap <leader>g :Goyo<cr>

" Tab Ident with |
	set list lcs=tab:\|\ ""

" UndoTree
	nnoremap <leader>u :UndotreeToggle<cr>

" Files on ctrl+p
    let g:Lf_ShortcutF = '<c-p>'

" Neoterm
    nnoremap <leader>ot :Ttoggle<cr>

" Quickrun
    nnoremap <leader>lr :QuickRun<cr>

" Sudo on files that require root permission
    cnoremap w!! execute 'silent! write !doas tee % >/dev/null' <bar> edit!

" Languages Settings
    let g:rustfmt_autosave = 1
    noremap <leader>mbr :RustRun<cr>
    noremap <leader>mbt :RustTest<cr>
