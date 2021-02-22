" Lightline
	let g:lightline = {}
" let g:lightline.separator = { 'left': "\ue0b8", 'right': "\ue0be" }
" let g:lightline.subseparator = { 'left': "\ue0b9", 'right': "\ue0b9" }
" let g:lightline.tabline_separator = { 'left': "\ue0bc", 'right': "\ue0ba" }
" let g:lightline.tabline_subseparator = { 'left': "\ue0bb", 'right': "\ue0bb" }
	let g:lightline.enable = {'statusline': 1,'tabline': 1}
	" let g:lightline.colorscheme = 'gruvbox_material'
	let g:lightline.active = { 'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename', 'modified' ] ],	'right': [ [ 'lineinfo' ], ['percent'], ['filetype']] }
	let g:lightline.tabline= {'left': [ ['buffers'] ],'right': [ ['close'] ]}
	let g:lightline.component_raw = {'buffers': 1}
	let g:lightline.component_expand= {'buffers': 'lightline#bufferline#buffers'}
	let g:lightline.component_type = {'buffers': 'tabsel'}
	let g:lightline.component_function = { 'filetype': 'MyFiletype','fileformat': 'MyFileformat',}
	let g:lightline#bufferline#show_number = 2
	let g:lightline#bufferline#unnamed = "untitled"
	let g:lightline#bufferline#enable_devicons = 1
	let g:lightline#bufferline#unicode_symbols = 1
	let g:lightline#bufferline#clickable = 1

	function! MyFiletype()
	 return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
	endfunction

	function! MyFileformat()
	 return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
	endfunction

" Buffer Mappings
	nmap <Leader>1 <Plug>lightline#bufferline#go(1)
	nmap <Leader>2 <Plug>lightline#bufferline#go(2)
	nmap <Leader>3 <Plug>lightline#bufferline#go(3)
	nmap <Leader>4 <Plug>lightline#bufferline#go(4)
	nmap <Leader>5 <Plug>lightline#bufferline#go(5)
	nmap <Leader>6 <Plug>lightline#bufferline#go(6)
	nmap <Leader>7 <Plug>lightline#bufferline#go(7)
	nmap <Leader>8 <Plug>lightline#bufferline#go(8)
	nmap <Leader>9 <Plug>lightline#bufferline#go(9)
	nmap <Leader>0 <Plug>lightline#bufferline#go(10)

