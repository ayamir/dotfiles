" ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗
" ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║
" ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║
" ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
" ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║
" ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝

let mapleader ="\<Space>"

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
Plug 'ryanoasis/vim-devicons'

Plug 'mhinz/vim-startify'
Plug 'godlygeek/tabular'
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'mbbill/undotree'

Plug 'rbgrouleff/bclose.vim'
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'

Plug 'jreybert/vimagit'

Plug 'Valloric/YouCompleteMe'
Plug 'pechorin/any-jump.vim'
Plug 'rust-lang/rust.vim'
Plug 'fatih/vim-go'
Plug 'sheerun/vim-polyglot'
Plug 'ap/vim-css-color'

Plug 'iamcco/markdown-preview.vim'
Plug 'jiangmiao/auto-pairs'

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

" Goyo
	noremap <leader>g :Goyo<CR>

" Tab Ident with |
	set list lcs=tab:\|\ ""

" UndoTree
	nnoremap <F5> :UndotreeToggle<CR>

" Files on ctrl+p
	nnoremap <C-p> :Files<CR>

" Sudo on files that require root permission
cnoremap w!! execute 'silent! write !doas tee % >/dev/null' <bar> edit!
