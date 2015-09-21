" CREATION     : 2015-09-21
" MODIFICATION : 2015-09-21

fun! ll#index#New(index, ...) abort " {{{1

	return {
				\ 'input'  : a:index,
				\ 'full'   : '',
				\ 'parsed' : '',
				\ 'pre'    : '',
				\ 'post'   : '',
				\ 'type'   : '',
				\ 'init' : function('s:Init'),
				\ 'get'  : function('s:Get')
			\ }
endfun
" 1}}}

fun! s:Init() dict " {{{1
	call self.get()
	return self
endfun
fun! s:Get() dict " {{{1
	" Method which:
	"	- Define pre, post & full index and his type (num, mark).
	"	- Return a formatted index.

	let l:index = !empty(self.input) ? self.input : '%1%. '
	" Remove quotes if they are present
	if l:index =~# '^[''""].*[''""]$'
		let l:index = strpart(l:index, 1, len(l:index) - 2)
	endif

	if l:index =~# '\v\%\d{1,}\%'
		let l:type = 'num'
		let l:preInd = substitute(l:index, '\v^(.*)\%\d{1,}\%.*$', '\1', '')
		let l:postInd = substitute(l:index, '\v^.*\%\d{1,}\%(.*)$', '\1', '')
		let l:parsInd = substitute(l:index, '\v^.*\%(\d{1,})\%.*$', '\1', '')
	else
		let l:type = 'mark'
		let l:parsInd = l:index
		let l:preInd = ''
		let l:postInd = ''
	endif

	let self.pre = l:preInd
	let self.post = l:postInd
	let self.full = l:index
	let self.type = l:type
	let self.parsed = l:parsInd

	return self
endfun
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
