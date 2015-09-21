" CREATION     : 2015-09-21
" MODIFICATION : 2015-09-21

fun! ll#selection#New(start, end, ...) abort " {{{1

	return {
				\ 'start' : a:start,
				\ 'end'   : a:end,
				\ 'lines' : a:end - a:start + 1,
				\ 'list'  : [],
				\ 'init'  : function('s:Init'),
				\ 'get'   : function('s:Get')
			\ }
endfun
" 1}}}

fun! s:Init() dict " {{{1
	call self.get()
	return self
endfun
fun! s:Get() dict " {{{1
	" Method which:
	"	- Define first & last lines in start & end properties.
	"	- Define a list containing the selection's lines.

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
	let self.list = getline(self.start, self.end)

	return self
endfun
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
