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
set completeopt=menuone,noselect


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

Plug 'vimlab/split-term.vim'
Plug 'glepnir/dashboard-nvim'
Plug 'glepnir/galaxyline.nvim'

Plug 'majutsushi/tagbar'
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'godlygeek/tabular'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-commentary'
Plug 'sbdchd/neoformat'

Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'

Plug 'airblade/vim-gitgutter'

Plug 'thinca/vim-quickrun'
Plug 'pechorin/any-jump.vim'

Plug 'neovim/nvim-lspconfig'
Plug 'kabouzeid/nvim-lspinstall'
Plug 'onsails/lspkind-nvim'

Plug 'hrsh7th/nvim-compe'
Plug 'tzachar/compe-tabnine', { 'do': './install.sh' }
Plug 'norcalli/snippets.nvim'

Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'rust-lang/rust.vim'
Plug 'alvan/vim-closetag'

Plug 'ap/vim-css-color'
Plug 'oknozor/illumination', { 'dir': '~/.illumination', 'do': '.install.sh' }
Plug 'jiangmiao/auto-pairs'
Plug 'rhysd/accelerated-jk'
Plug 'justinmk/vim-sneak'
Plug 'junegunn/vim-slash'

call plug#end()

colorscheme nord

" Edit Setting
autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g'\"" | endif
autocmd! bufwritepost $MYVIMRC source $MYVIMRC

augroup fmt
	autocmd!
	autocmd BufWritePre * Neoformat
augroup END

augroup RELOAD
	autocmd!
	" Disables automatic commenting on newline:
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

	" Automatically deletes all trailing whitespace on save.
	autocmd BufWritePre * %s/\s\+$//e
augroup END

" Automatically change work directory
autocmd BufEnter * silent! lcd %:p:h

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0
autocmd FileType c,cpp,rust,go setlocal tabstop=4

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
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k

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

" Tab Ident with |
set list lcs=tab:\|\ ""

" Telescope
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" closetag
let g:closetag_filenames = '*.html,*.xhtml,*.phtml,*.xml'
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx'
let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
			\ 'typescript.tsx': 'jsxRegion,tsxRegion',
			\ 'javascript.jsx': 'jsxRegion',
			\ 'typescriptreact': 'jsxRegion,tsxRegion',
			\ 'javascriptreact': 'jsxRegion',
			\ }
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'

" vim-slash
noremap <plug>(slash-after) zz

" vim-sneak
let g:sneak#label = 1
map f <Plug>Sneak_s
map F <Plug>Sneak_S
map t <Plug>Sneak_t
map T <Plug>Sneak_T

" Split-vim
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

" Sudo on files that require root permission
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Languages Settings
autocmd FileType go nnoremap <buffer> <slient> <C-o> :GoDefPop<cr>
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

