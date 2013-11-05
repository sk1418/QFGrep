" QFGrep  : a vim plugin to filter Quickfix entries
" Author  : Kai Yuan <kent.yuan@gmail.com>
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
if exists("g:autoloaded_QFGrep") || &cp
  finish
endif
let g:autoloaded_QFGrep = 1

let s:origQF        = !exists("s:origQF")? [] : s:origQF
"the message header
let s:msgHead = '[QFGrep] ' 

"read user's highlighting setting
if !exists('g:QFG_hi_prompt')
  let g:QFG_hi_prompt='ctermbg=68 ctermfg=16 guibg=#5f87d7 guifg=black'
endif


if !exists('g:QFG_hi_info')
  let g:QFG_hi_info = 'ctermbg=113 ctermfg=16 guibg=#87d75f guifg=black'
endif

if !exists('g:QFG_hi_error')
  let g:QFG_hi_error = 'ctermbg=167 ctermfg=16 guibg=#d75f5f guifg=black'
endif

execute 'hi QFGPrompt ' . g:QFG_hi_prompt
execute 'hi QFGInfo '   . g:QFG_hi_info
execute 'hi QFGError '  . g:QFG_hi_error



function! QFGrep#init_origQF()
  let s:origQF = []
endfunction

function! QFGrep#fill_origQF()
  let s:origQF = getqflist()
endfunction

"do grep on quickfix entries
function! QFGrep#GrepQuickFix(invert)
  "store original quickfix lists, so that later could be restored
  let s:origQF = len( s:origQF )>0? s:origQF : getqflist()
  let all = getqflist()
  if empty(all)
    call QFGrep#PrintErrMsg('Quickfix window is empty. Nothing could be grepped. ')
    return
  endif
  let cp = deepcopy(all)
  call inputsave()
  echohl QFGPrompt
  let pat = input( s:msgHead . 'Pattern' . (a:invert?' (Invert-matching):':':'))
  echohl None
  call inputrestore()
  "clear the cmdline
  exec 'redraw' 
  if empty(pat)
    call QFGrep#PrintErrMsg("Empty pattern is not allowed")
    return
  endif
  try
    for d in cp
      if (!a:invert)
        if ( bufname(d['bufnr']) !~ pat && d['text'] !~ pat)
          call remove(cp, index(cp,d))
        endif
      else " here do invert matching
        if (bufname(d['bufnr']) =~ pat || d['text'] =~ pat)
          call remove(cp, index(cp,d))
        endif
      endif
    endfor
    if empty(cp)
      call QFGrep#PrintErrMsg('Empty resultset, aborted.')
    else		"found entries
      call setqflist(cp)
      call QFGrep#PrintHLInfo(len(cp) . ' entries in Grep result.')
    endif
  catch /^Vim\%((\a\+)\)\=:E/
    call QFGrep#PrintErrMsg('Pattern invalid')
  endtry

endfunction


fun! QFGrep#RestoreQuickFix()
  if len(s:origQF) > 0
    call setqflist(s:origQF)
    call QFGrep#PrintHLInfo('Quickfix entries restored.')
  else
    call QFGrep#PrintErrMsg("Nothing can be restored")
  endif

endf


fun! QFGrep#PrintErrMsg(errMsg)
  echohl QFGError
  echon s:msgHead . a:errMsg
  echohl None
endf


"print Highlighted info
fun! QFGrep#PrintHLInfo(msg)
  echohl QFGInfo
  echon s:msgHead .  a:msg
  echohl None
endf

" vim: ts=2:tw=80:shiftwidth=2:tabstop=2:fdm=marker:expandtab:
