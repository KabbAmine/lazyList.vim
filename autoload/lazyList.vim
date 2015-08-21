" Lazy list global dictionnary.

" CREATION     : 2015-08-10
" MODIFICATION : 2015-08-21
" MAINTAINER   : Kabbaj Amine <amine.kabb@gmail.com>
" LICENSE      : The MIT License (MIT)

fun! lazyList#New(start, end, ...) abort " {{{1

	let l:index = exists('a:1') ? a:1 : ''

	return {
				\ 'init'         : function('lazyList#Init'),
				\ 'indexList'    : [],
				\ 'outputList'   : [],
				\ 'toggle'       : function('lazyList#ToggleList'),
				\ 'getIndexList' : function('lazyList#GetIndexList'),
				\ 'selection': {
					\ 'start' : a:start,
					\ 'end'   : a:end,
					\ 'lines' : a:end - a:start + 1,
					\ 'list'  : [],
					\ 'get'   : function('lazyList#GetSelection')
				\ },
				\ 'index': {
					\ 'input'  : l:index,
					\ 'full'   : '',
					\ 'parsed' : '',
					\ 'pre'    : '',
					\ 'post'   : '',
					\ 'type'   : '',
					\ 'get'    : function('lazyList#GetIndex')
				\ }
			\ }
endfun
" 1}}}

fun! lazyList#GetSelection() dict " {{{1
	" Method for lazylist.selection which:
	"	- Define first & last lines in start & end properties.
	"	- Return a list of the selection's lines.

	let l:start = self.start
	let l:end = self.end
	let l:lines = self.lines

	" If the number of selected lines is not equal to the number of file's 
	" lines, then we execute the NORMAL mode behavior.
	if l:lines ==# line('$')

		" NORMAL mode ---> 
		"	Automatically select paragraph delimited by 2 empty lines or
		"	different indentation size.
		let l:currLine = line('.')

		" Get 1st line
		let l:line = l:currLine
		while indent(l:line) ==# indent(l:currLine)
			let l:line -= 1
		endwhile
		let l:firstDiffIndLine = l:line
		let l:firstEmptyLine = search('^$', 'nb', 1)
		if !l:firstDiffIndLine && !l:firstEmptyLine
			let l:firstLine = 1
		else
			let l:firstLine = max([l:firstDiffIndLine, l:firstEmptyLine]) + 1
		endif

		" Get last line
		let l:line = l:currLine
		while indent(l:line) ==# indent(l:currLine)
			let l:line += 1
		endwhile
		let l:lastDiffIndLine = l:line
		let l:lastEmptyLine = search('^$', 'n', line('$'))
		if !l:lastDiffIndLine && !l:lastEmptyLine
			let l:lastLine = line('$')
		elseif !l:lastEmptyLine && l:lastDiffIndLine
			let l:lastLine = l:lastDiffIndLine - 1
		else
			let l:lastLine = min([l:lastDiffIndLine, l:lastEmptyLine]) - 1
		endif

	else
		" VISUAL mode --->
		"	The first & last lines are already known (Provided by the
		"	command).
		"
		let l:firstLine = l:start
		let l:lastLine = l:end
	endif

	let self.start = l:firstLine
	let self.end = l:lastLine

	return getline(self.start, self.end)

endfun
fun! lazyList#GetIndex() dict " {{{1
	" Method for lazylist.index which:
	"	- Define pre, post & full index and his type (num, mark).
	"	- Return a formatted index.

	let l:index = !empty(self.input) ? self.input : '%1%. '
	" Remove quotes if they are present
	if l:index =~# '^[''""].*[''""]$'
		let l:index = strpart(l:index, 1, len(l:index) - 2)
	endif

	if l:index =~# '%\d%'
		let l:type = 'num'
		let l:preInd = substitute(l:index, '^\(.*\)%\d%.*$', '\1', '')
		let l:postInd = substitute(l:index, '^.*%\d%\(.*\)$', '\1', '')
		let l:parsInd = substitute(l:index, '^.*%\(\d\)%.*$', '\1', '')
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

	return l:parsInd

endfun
fun! lazyList#GetIndexList() dict " {{{1
	" Method for lazylist.index which:
	"	- Return a list of indicies (pre + ind + post)

	let l:Index = self.index
	let l:Selection = self.selection

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
fun! lazyList#Init() dict " {{{1
	" Initialize what needed for lazylist (A kind of constructor)

	let l:Selection = self.selection
	let l:Index = self.index

	let l:Selection.list = l:Selection.get()
	let l:Index.parsed = l:Index.get()

	let self.indexList = self.getIndexList()
endfun
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
