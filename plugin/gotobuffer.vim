"
" GoToBuffer
"
" Author: Martin Lundberg
" Version: 0.1
"
"if exists('g:loaded_gotobuffer')
	"finish
"endif
"let g:loaded_gotobuffer = 1

if !exists('g:gotobuffer_maxheight')
	let g:gotobuffer_maxheight = 10
endif

function! s:GoToBufferToggle()
	if bufexists(bufnr("__GOTOBUFFER__"))
		execute ":" . bufnr("__GOTOBUFFER__") . 'bwipeout'
		return
	endif

	let s:pattern = ''
	let buffers = s:get_all_buffers()

	let height = len(buffers) < g:gotobuffer_maxheight ? len(buffers) : g:gotobuffer_maxheight
	call s:create_window(height)
	call s:init_mappings()

	" Remove insert abbreviations from buffer
	iabc <buffer>

	setlocal modifiable
	for filename in buffers
		put = filename
	endfor
	setlocal nomodifiable
endfunction

function! s:handle_key(char)
	let s:pattern .= a:char
	call s:filter_list()
endfunction

function! s:filter_list()
	let buffers = s:get_all_buffers()
	let height = len(buffers) < g:gotobuffer_maxheight ? len(buffers) : g:gotobuffer_maxheight
	call s:set_window_height(height)

	setlocal modifiable
	" Clear the buffer
	silent %delete
	echo s:pattern
	for filename in buffers
		put = filename
	endfor
	setlocal nomodifiable
endfunction

function! s:init_mappings()
	" Mappings for handling pattern
	let numbers = [0,1,2,3,4,5,6,7,8,9]
	let lowercase = split('abcdefghijklmnopqrstuvwxys', '\zs')
	let uppercase = split('ABCDEFGHIJKLMNOPQRSTUVWXYS', '\zs')
	"let punctuation = split('<>`@#~!"$%&/()=+*-_.,;:?\{}[] ', '\zs')
	let characters = numbers + lowercase + uppercase
	for char in characters
		exec 'nnoremap <buffer> ' . char . ' :call <SID>handle_key("' . char . '")<CR>'
	endfor
	" Function mappings
	nnoremap <buffer> <CR> :call <SID>LoadSelectedBuffer()<CR>
	nnoremap <buffer> <Esc> :call <SID>close_window()<CR>
	nnoremap <buffer> <BS> :call <SID>backspace()<CR>
	nnoremap <buffer> <C-N> :call <SID>move_down()<CR>
	nnoremap <buffer> <C-P> :call <SID>move_up()<CR>
endfunction

function! s:create_window(height)
	" Create a new window and set some local options
	execute "botright " . a:height . "new __GOTOBUFFER__"
	setlocal noshowcmd
	setlocal noswapfile
	setlocal buftype=nofile
	setlocal bufhidden=hide
	setlocal nowrap
	setlocal nobuflisted
	setlocal nospell
	setlocal nomodified
	setlocal nonumber
	setlocal cursorline
endfunction

function! s:set_window_height(height)
	exec 'n' . height
endfunction

function! s:close_window()
	bwipeout
endfunction

function! s:backspace()
	let s:pattern = strpart(s:pattern, 0, (strchars(s:pattern) - 1))
	echo s:pattern
	call s:filter_list()
endfunction

function! s:move_up()
	let line = line('.') - 1
	call cursor(line, 0)
endfunction

function! s:move_down()
	let line = line('.') + 1
	call cursor(line, 0)
endfunction

function! s:get_all_buffers()
	let buffers = []
	let bufcount = bufnr('$') " bufnr('$') gets the latest buffer number
	let i = 0

	while i <= bufcount
		let i += 1
		let bufname = bufname(l:i)
		if strlen(bufname) && getbufvar(i, '&modifiable') && getbufvar(i, '&buflisted')
			if bufname =~ s:pattern
				call add(buffers, bufname)
			endif
		endif
	endwhile

	return buffers
endfunction

function! s:LoadSelectedBuffer()
	let filename = s:GetSelectedBuffer()
	" Remove the buffer list
	bwipeout
	exec ":buffer " . l:filename
endfunction

function! s:GetSelectedBuffer()
	let line = getline('.')
	return line
endfunction

nmap <leader>f :call <SID>GoToBufferToggle()<CR>
