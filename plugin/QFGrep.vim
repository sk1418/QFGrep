" QFGrep  : a vim plugin to filter Quickfix entries
" Author  : Kai Yuan <kent.yuan@gmail.com>
" Version : 1.0.0
" License: {{{
"Copyright (c) 2013 Kai Yuan
"Permission is hereby granted, free of charge, to any person obtaining a copy of
"this software and associated documentation files (the "Software"), to deal in
"the Software without restriction, including without limitation the rights to
"use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
"the Software, and to permit persons to whom the Software is furnished to do so,
"subject to the following conditions:
"
"The above copyright notice and this permission notice shall be included in all
"copies or substantial portions of the Software.
"
"THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
"IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
"FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
"COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
"IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
"CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
if exists("g:loaded_QFGrep") || &cp
  finish
endif

let g:loaded_GrepQF = 1

let g:origQF =  !exists("g:origQF")? [] : g:origQF

"mappings
let g:QFG_Grep = !exists('g:QFG_Grep')? '<Leader>g' : g:QFG_Grep
let g:QFG_Restore = !exists('g:QFG_Restore')? '<Leader>r' : g:QFG_Restore

"highlighting
if !exists('g:QFG_hi_prompt')
  let g:QFG_hi_prompt='ctermbg=68 ctermfg=16 guibg=#5f87d7 guifg=black'
endif

if !exists('g:QFG_hi_info')
  let g:QFG_hi_info = 'ctermbg=113 ctermfg=16 guibg=#87d75f guifg=black'
endif

if !exists('g:QFG_hi_error')
  let g:QFG_hi_error = 'ctermbg=167 ctermfg=16 guibg=#d75f5f guifg=black'
endif

"the message header
let s:msgHead = '[QFGrep] ' 

"do grep on quickfix entries
function! <SID>GrepQuickFix()
  "store original quickfix lists, so that later could be restored
  let g:origQF = len( g:origQF )>0? g:origQF : getqflist()
  let all = getqflist()
  if empty(all)
    call PrintErrMsg('Quickfix window is empty. Nothing could be grepped. ')
    return
  endif
  let cp = deepcopy(all)
  call inputsave()
  echohl QFGPrompt
  let pat = input( s:msgHead . 'Pattern:')
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
  execute 'hi QFGPrompt '. g:QFG_hi_prompt
  execute 'hi QFGInfo '. g:QFG_hi_info
  execute 'hi QFGError '. g:QFG_hi_error
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


   " vim:ts=2:tw=80:shiftwidth=2:tabstop=2:fdm=marker:expandtab
