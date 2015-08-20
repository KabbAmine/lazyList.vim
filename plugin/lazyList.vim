" Be lazy & create your lists quickly and easily.

" VERSION      : 0.1
" CREATION     : 2015-08-10
" MODIFICATION : 2015-08-12
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

" Main command {{{1
command! -bar -range -nargs=? LazyList :let s:lazyList = {}
			\| if !empty(getline('.'))
				\| let s:lazyList = lazyList#New(<line1>, <line2>, <f-args>)
				\| call s:lazyList.init()
				\| call s:lazyList.toggle()
			\| endif
" Generate mapping(s) dynamically {{{1
if exists('g:lazylist_maps')
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
" 1}}}

" Restore default vim options {{{1
let &cpoptions = s:saveCpoptions
unlet s:saveCpoptions
" 1}}}

" vim:ft=vim:fdm=marker:fmr={{{,}}}:
