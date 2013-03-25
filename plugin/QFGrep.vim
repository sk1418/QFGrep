" QFGrep  : a vim plugin to filter Quickfix entries
" Author  : Kai Yuan <kent.yuan@gmail.com>
" Version : 1.0.0

if exists("g:loaded_GrepQF") || &cp
		finish
endif

let g:loaded_GrepQF = 1.0.0

let g:origQF =  !exists("g:origQF")? [] : g:origQF

"mappings
let g:QFG_Grep = !exists('g:QFG_Grep')? '<Leader>g' : g:QFG_Grep
let g:QFG_Restore = !exists('g:QFG_Restore')? '<Leader>r' : g:QFG_Restore

"the message header
let s:msgHead = '[QFGrep] ' 

"do grep on quickfix entries
function! <SID>GrepQuickFix()
		"		"store original quickfix lists, so that later could be restored
		let g:origQF = len( g:origQF )>0? g:origQF : getqflist()
		let all = getqflist()
		if empty(all)
				call PrintErrMsg('Quickfix window is empty. Nothing could be grepped. ')
				return
		endif
		let cp = deepcopy(all)
		call inputsave()
		echohl QFGPrompt
		let pat = input( s:msgHeader . 'Pattern:')
		echohl None
		call inputrestore()
		"clear the cmdline
		exec 'redraw' 
		if empty(pat)
				call PrintErrMsg("Empty pattern is not allowed")
				return
		endif
		try
				for d in cp
						if bufname(d['bufnr']) !~ pat && d['text'] !~ pat
								call remove(cp, index(cp,d))
						endif
				endfor
				if empty(cp)
						call PrintErrMsg('Empty resultset, aborted.')
				else		"found entries
						call setqflist(cp)
						call PrintHLInfo(len(cp) . ' entries in Grep result.')
				endif
		catch /^Vim\%((\a\+)\)\=:E/
				call PrintErrMsg('Pattern invalid')
		endtry

endfunction


fun! <SID>RestoreQuickFix()
		if !hasmapto(':RestoreQF<cr>')
		if !hasmapto(':RestoreQF<cr>')
		if !hasmapto(':RestoreQF<cr>')
				nnoremap <buffer><silent><leader>r :RestoreQF<cr>
		endif
				nnoremap <buffer><silent><leader>r :RestoreQF<cr>
		endif
				nnoremap <buffer><silent><leader>r :RestoreQF<cr>
		endif
		if len(g:origQF) > 0
				call setqflist(g:origQF)
				call PrintHLInfo('Quickfix entries restored.')
		else
				call PrintErrMsg("Nothing can be restored")
		endif

endf


fun! PrintErrMsg(errMsg)
		echohl QFGError
		echon s:msgHead.a:errMsg
		echohl None
endf


"print Highlighted info
fun! PrintHLInfo(msg)
		echohl QFGInfo
		echon s:msgHead.a:msg
		echohl None
endf

"autocommands 
fun! <SID>FTautocmdBatch()
		hi QFGPrompt ctermbg=68 ctermfg=16 guibg=#5f87d7 guifg=black
		hi QFGInfo ctermbg=113 ctermfg=16 guibg=#87d75f guifg=black
		hi QFGError ctermbg=167 ctermfg=16 guibg=#d75f5f guifg=black
		command! QFGrep call <SID>GrepQuickFix()
		command! QFRestore call <SID>RestoreQuickFix()
		"mapping
		execute 'nnoremap <buffer><silent>' . g:QFG_Grep . ' :QFGrep<cr>'
		execute 'nnoremap <buffer><silent>' . g:QFG_Restore . ' :QFRestore<cr>'
endf

augroup QFG
		au!
    autocmd QuickFixCmdPre * let g:origQF = []
		autocmd QuickFixCmdPost * let g:origQF = getqflist() 
		autocmd FileType qf call <SID>FTautocmdBatch()
augroup end


  " vim:ts=2:tw=2:tabstop=2
