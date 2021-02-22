" Init.vim Setting
	nnoremap <leader>s :source $MYVIMRC<cr>

" Plug Setting
	nnoremap <leader><leader>i :PlugInstall<cr>
	nnoremap <leader><leader>u :PlugUpdate<cr>
	nnoremap <leader><leader>c :PlugClean<cr>

" Clipboard
	set go=a
	set clipboard+=unnamedplus

" Clipboard Remap
	vnoremap  <leader>y  "+y
	nnoremap  <leader>Y  "+yg_
	nnoremap  <leader>y  "+y
	nnoremap  <leader>yy  "+yy
	nnoremap <leader>p "+p
	nnoremap <leader>P "+P
	vnoremap <leader>p "+p
	vnoremap <leader>P "+P

" TagBar
	nmap <leader>t :TagbarToggle<CR>

" Spell-check set to <leader>o, 'o' for 'orthography':
	map <leader>o :setlocal spell! spelllang=en_us<CR>

" Split Navigation shortcuts
	map <leader>wv :vsplit<CR>
	map <leader>ws :split<CR>
	map <leader>wh <C-w>h
	map <leader>wj <C-w>j
	map <leader>wk <C-w>k
	map <leader>wl <C-w>l

"Buffer Navigation
	noremap <C-c>l :bn<CR>
	noremap <C-c>h :bp<CR>
	noremap <C-t> :tabnew split<CR>

" Keep selection after shift
	vnoremap < <gv
	vnoremap > >gv

" Replace all is aliased to S.
	nnoremap S :%s//g<Left><Left>
