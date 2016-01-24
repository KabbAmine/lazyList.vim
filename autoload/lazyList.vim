" CREATION     : 2015-08-10
" MODIFICATION : 2016-01-24

fun! lazyList#New(start, end, ...) abort " {{{1

	let l:index = exists('a:1') ? a:1 : ''

	return {
				\ 'indexList'    : [],
				\ 'outputList'   : [],
				\ 'init'         : function('lazyList#Init'),
				\ 'toggle'       : function('lazyList#ToggleList'),
				\ 'selection'    : ll#selection#New(a:start, a:end).init(),
				\ 'index'        : ll#index#New(l:index).init()
			\ }
endfun
" 1}}}

fun! lazyList#Init() dict " {{{1
	let self.indexList = s:GetIndexList(self)
	return self
endfun
fun! lazyList#ToggleList() dict " {{{1
	" Method for lazylist which add or remove indicies.

	let l:Selection = self.selection
	let l:Index = self.index

	let l:start = l:Selection.start
	let l:index = l:Index.full

	let l:indicies = self.indexList
	let l:linesList = l:Selection.list

	let l:initialPos = getpos('.')
	" Length of futur index in current line
	let l:indexLen = strlen(l:indicies[l:initialPos[1] - l:start])

	" Get index of first non blank character (0 if no indentation)
	let l:firstCharIndex = match(l:linesList[0], '\S')
	" Check if index in 1st line is already present ... (2)
	if strpart(l:linesList[0], l:firstCharIndex, len(l:indicies[0])) ==# l:indicies[0]
		" (2) ... if yes, remove all of them
		for l:i in range(0, len(l:linesList) - 1)
			let l:currentFirstCharIndex = match(l:linesList[l:i], '\S')
			if match(l:linesList[l:i][expand(l:currentFirstCharIndex):], escape(l:indicies[l:i], '-^$ ./[{}]')) ==# 0
				let l:linesList[l:i] = strpart(l:linesList[l:i], 0, l:currentFirstCharIndex) . strpart(l:linesList[l:i], l:currentFirstCharIndex + strlen(l:indicies[l:i]))
			else
				" If no index is present (e.g A new line was inserted), we go to
				" the next one (Works only for marks).
				let l:i -= 1
			endif
		endfor
		let l:initialPos[2] -= l:indexLen
	else
		" (2) ... if not, add them
		for l:i in range(0, len(l:linesList) - 1)
			let l:currentFirstCharIndex = match(l:linesList[l:i], '\S')
			let l:linesList[l:i] = strpart(l:linesList[l:i], 0, l:currentFirstCharIndex) . l:indicies[l:i] . strpart(l:linesList[l:i], l:currentFirstCharIndex)
		endfor
		let l:initialPos[2] += l:indexLen
	endif
	" And finally replace all the lines by the new ones
	for l:i in range(0, len(l:linesList) - 1)
		call setline(l:start + l:i, l:linesList[l:i])
	endfor

	call setpos('.', l:initialPos)
endfun
" 1}}}

fun! s:GetIndexList(ll) abort " {{{1
	" Take a lazylist dict as arg and returns a list of indices (pre + ind + post)
	" P.S: I'm using a normal function instead of a method to make it
	" compatible with vim <= 7.4

	let l:Index = a:ll.index
	let l:Selection = a:ll.selection

	let l:start = l:Selection.start
	let l:end = l:Selection.end
	let l:index = l:Index.parsed
	let l:preInd = l:Index.pre | let l:postInd = l:Index.post
	let l:typeInd = l:Index.type

	let l:indicies = []
	
	if l:typeInd ==# 'num'
		" Numerical indicies
		let l:initialInd = l:index
		let l:lastInd = l:end - l:start + l:initialInd
		for l:i in range(l:initialInd, l:lastInd)
			call add(l:indicies, l:preInd . l:i . l:postInd)
		endfor
	elseif l:typeInd ==# 'mark'
		" Mark indicies
		for l:i in range(1, l:end - l:start + 1)
			call add(l:indicies, l:index)
		endfor
	endif

	return l:indicies
endfun
" }}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
