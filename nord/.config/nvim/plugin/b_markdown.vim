" Markdown
	let system = system('uname -s')
	let g:mkdp_path_to_chrome = '/usr/bin/google-chrome-stable %U'
	nmap <silent> <F7> <Plug>MarkdownPreview
	imap <silent> <F7> <Plug>MarkdownPreview
	nmap <silent> <F8> <Plug>StopMarkdownPreview
	imap <silent> <F8> <Plug>StopMarkdownPreview
