" YCM
" 如果不指定python解释器路径，ycm会自己搜索一个合适的(与编译ycm时使用的python版本匹配)
" let g:ycm_server_python_interpreter = '/usr/bin/python2.7'
	let g:ycm_confirm_extra_conf = 0
	let g:ycm_error_symbol = '✗'
	let g:ycm_warning_symbol = '✹'
	let g:ycm_seed_identifiers_with_syntax = 1
	let g:ycm_complete_in_comments = 1
	let g:ycm_complete_in_strings = 1
	let g:ycm_collect_identifiers_from_tags_files = 1
	let g:ycm_semantic_triggers =  {
				\   'c' : ['->', '.','re![_a-zA-z0-9]'],
				\   'objc' : ['->', '.', 're!\[[_a-zA-Z]+\w*\s', 're!^\s*[^\W\d]\w*\s',
				\             're!\[.*\]\s'],
				\   'ocaml' : ['.', '#'],
				\   'cpp,objcpp' : ['->', '.', '::','re![_a-zA-Z0-9]'],
				\   'perl' : ['->'],
				\   'php' : ['->', '::'],
				\   'cs,java,javascript,typescript,d,python,perl6,scala,vb,elixir,go' : ['.'],
				\   'ruby' : ['.', '::'],
				\   'lua' : ['.', ':'],
				\   'erlang' : [':'],
				\ }
	nnoremap <leader>u :YcmCompleter GoToDeclaration<cr>
	" 已经用cpp-mode插件提供的转到函数实现的功能
	" nnoremap <leader>i :YcmCompleter GoToDefinition<cr>
	nnoremap <leader>o :YcmCompleter GoToInclude<cr>
	nnoremap <leader>ff :YcmCompleter FixIt<cr>
	nmap <F5> :YcmDiags<cr>
