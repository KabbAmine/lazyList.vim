" Be lazy & create your lists quickly and easily.

" VERSION      : 0.6
" CREATION     : 2015-08-10
" MODIFICATION : 2015-09-22
" MAINTAINER   : Kabbaj Amine <amine.kabb@gmail.com>
" LICENSE      : The MIT License (MIT)

" Vim options {{{1
if exists("g:lazylist_loaded")
    finish
endif
let g:lazylist_loaded = 1

" To avoid conflict problems.
let s:saveCpoptions = &cpoptions
set cpoptions&vim
" }}}

" General options {{{1
let g:lazylist_omap = exists('g:lazylist_omap') ? g:lazylist_omap : ''
let g:lazylist_maps = exists('g:lazylist_maps') ? g:lazylist_maps : []
" 1}}}
" Main command {{{1
command! -bar -range=% -nargs=? LazyList
			\ if !empty(getline('.'))
				\| call lazyList#New(<line1>, <line2>, <f-args>).init().toggle()
			\| endif
" Generate mapping(s) dynamically {{{1
if !empty(g:lazylist_maps)
	let s:prefKey = g:lazylist_maps[0]
	let s:maps = keys(g:lazylist_maps[1])
	let s:patterns = values(g:lazylist_maps[1])
	for s:i in range(0, len(s:maps) - 1)
		let s:map = s:prefKey . s:maps[s:i]
		let s:nplug = '<Plug>(LazyList' . (s:i + 1) . ')'
		let s:vplug = '<Plug>(VLazyList' . (s:i + 1) . ')'
		let s:cmd = empty(s:patterns[s:i]) ?
					\ ':LazyList' :
					\ ":LazyList '" . s:patterns[s:i] . "' "

		exec ':nmap <silent> ' . s:nplug . ' ' . s:cmd
		exec ':nmap ' . s:map . ' ' . s:nplug . '<CR>'
		exec ':vmap <silent> ' . s:vplug . ' ' . s:cmd
		exec ':vmap ' . s:map . ' ' . s:vplug . '<CR>'
	endfor
endif
" Text-object mapping {{{1
if !empty(g:lazylist_omap)
	execute 'vnoremap <silent> ' . g:lazylist_omap . ' :<C-u>call <SID>VisualSelect()<CR>'
	execute 'omap <silent> ' . g:lazylist_omap . ' :normal v' . g:lazylist_omap . '<CR>'
	fun! <SID>VisualSelect() abort
		if !empty(getline('.'))
			let l:s = ll#selection#New(1, line('$')).init()
			execute 'normal! ' . l:s.start . 'ggV' . l:s.end . 'gg'
		endif
	endfun
endif
" 1}}}

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
