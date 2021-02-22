" Behavior
	syntax on
	syntax enable

	filetype on
	filetype plugin on
	filetype indent on

	set ttimeoutlen=0
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
	set cmdheight=1
	set laststatus=2
	set noshowmode
	set nohlsearch
	set bg=dark


" Command Completion
	set wildmenu
	set wildmode=longest:full,full
	set completeopt-=preview
