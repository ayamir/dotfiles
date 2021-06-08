" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝

let mapleader =","

" Behavior
syntax on
syntax enable

filetype on
filetype plugin on
filetype indent on

set ttimeoutlen=0
set updatetime=300
set splitbelow splitright
set conceallevel=0

set autoindent
set smartindent
set cindent
set cinoptions=g0,:0,N-s,(0

set noexpandtab
set foldmethod=indent
set tabstop=2
set shiftwidth=2
set softtabstop=2
set smarttab

set wrap linebreak nolist
set shortmess+=c
set whichwrap+=<,>,h,l
"set virtualedit=block,nordmore
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

Plug 'sonph/onehalf', {'rtp': 'vim/'}
Plug 'arcticicestudio/nord-vim'
Plug 'ryanoasis/vim-devicons'

Plug 'vimlab/split-term.vim'
Plug 'chxuan/vimplus-startify'
Plug 'godlygeek/tabular'
Plug 'bluz71/vim-moonfly-statusline'
Plug 'wfxr/minimap.vim'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'luochen1990/rainbow'

Plug 'Yggdroot/indentLine'
" Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'honza/vim-snippets'
Plug 'google/vim-maktaba'
Plug 'google/vim-codefmt'
Plug 'google/vim-glaive'

Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }

Plug 'airblade/vim-gitgutter'

Plug 'cdelledonne/vim-cmake'
Plug 'thinca/vim-quickrun'
Plug 'pechorin/any-jump.vim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'metalelf0/supertab'

Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'alvan/vim-closetag'

Plug 'junegunn/goyo.vim'
Plug 'ap/vim-css-color'
Plug 'plasticboy/vim-markdown'
Plug 'jiangmiao/auto-pairs'
Plug 'easymotion/vim-easymotion'
Plug 'rhysd/accelerated-jk'
Plug 'junegunn/vim-slash'

Plug 'Shougo/echodoc.vim'

call plug#end()

colorscheme nord

" Edit Setting
	autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif
  autocmd! bufwritepost $MYVIMRC source $MYVIMRC

  augroup autoformat_settings
    autocmd FileType bzl AutoFormatBuffer buildifier
    autocmd FileType c,cpp,proto,javascript,arduino AutoFormatBuffer clang-format
    autocmd FileType dart AutoFormatBuffer dartfmt
    autocmd FileType go AutoFormatBuffer gofmt
    autocmd FileType gn AutoFormatBuffer gn
    autocmd FileType html,css,sass,scss,less,json AutoFormatBuffer js-beautify
    autocmd FileType java AutoFormatBuffer google-java-format
    autocmd FileType python AutoFormatBuffer yapf
    " Alternative: autocmd FileType python AutoFormatBuffer autopep8
    autocmd FileType rust AutoFormatBuffer rustfmt
    autocmd FileType vue AutoFormatBuffer prettier
  augroup END

  augroup RELOAD
      autocmd!
      " Close vim when Nerdtree is last window
      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

      " Disables automatic commenting on newline:
      autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

      " Automatically deletes all trailing whitespace on save.
      autocmd BufWritePre * %s/\s\+$//e
  augroup END

  " Automatically change work directory
  autocmd BufEnter * silent! lcd %:p:h

  autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
  autocmd FileType c,cpp,rust,go setlocal tabstop=2

" Init.vim Setting
  imap jj <Esc>
  nnoremap <leader><leader>v :tabe $MYVIMRC<cr>

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

" Buffer Navigation
	noremap <A-j> :bn<cr>
	noremap <A-k> :bp<cr>
  noremap <A-q> :bw<cr>
  noremap <A-S-q> :bw!<cr>

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

" Files on ctrl+p
  let g:Lf_ShortcutF = '<c-p>'

" Supertab
  let g:SuperTabDefaultCompletionType = "<c-n>"

" vim-slash
  noremap <plug>(slash-after) zz

" Split-vim
  noremap <F3> :set hls!<cr>
  noremap <F5> :Term<CR>
  noremap <C-w>t :Term<CR>
  noremap <C-w>T: VTerm<CR>

" AnyJump
  " Normal mode: Jump to definition under cursore
  nnoremap <leader>jj :AnyJump<CR>
  " Visual mode: jump to selected text in visual mode
  xnoremap <leader>jv :AnyJumpVisual<CR>
  " Normal mode: open previous opened file (after jump)
  nnoremap <leader>ab :AnyJumpBack<CR>
  " Normal mode: open last closed search window again
  nnoremap <leader>al :AnyJumpLastResults<CR>

" Minimap
  nnoremap <leader>mt :MinimapToggle<cr>
  nnoremap <leader>mr :MinimapRefresh<cr>

" Easymotion
	nmap <Leader>s <Plug>(easymotion-overwin-f)
	nmap <leader><leader>s <Plug>(easymotion-overwin-f2)

	" Move to line
	map <Leader>L <Plug>(easymotion-bd-jk)
	nmap <Leader>L <Plug>(easymotion-overwin-line)

	" Move to word
	map  <Leader>w <Plug>(easymotion-bd-w)
	nmap <Leader>w <Plug>(easymotion-overwin-w)

" moonfly-line
  let g:moonflyWithGitBranchCharacter = 1
	let g:moonflyWithNerdIcon = 1
	let g:moonflyLinterIndicator = "✖"
	let g:moonflyDiagnosticsIndicator = "✖"
	let g:moonflyWithCocIndicator = 1

" Sudo on files that require root permission
	cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Languages Settings
    let g:rainbow_active = 1

    autocmd FileType go nmap <leader>mbb <Plug>(go-build)
    autocmd FileType go nmap <leader>mbr <Plug>(go-run)
    autocmd FileType go nmap <leader>mds :GoDebugStart<cr>
    autocmd FileType go nmap <leader>mdb :GoDebugBreakpoint<cr>
    autocmd FileType go nmap <leader>mdc :GoDebugContinue<cr>
    autocmd FileType go nmap <leader>mdo :GoDebugStepOut<cr>
    autocmd FileType go nmap <leader>mdt :GoDebugStop<cr>

    autocmd FileType rust nmap <leader>mbb :Cbuild<cr>
    autocmd FileType rust nmap <leader>mbt :Ctest<cr>
    autocmd FileType rust nmap <leader>mbr :Crun<cr>
