" QFGrep  : a vim plugin to filter Quickfix entries
" Author  : Kai Yuan <kent.yuan@gmail.com>
" License: {{{1
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
"
"init variables {{{1
if exists("g:autoloaded_QFGrep") || &cp
  finish
endif
let g:autoloaded_QFGrep = 1

let s:origQF        = !exists("s:origQF")? [] : s:origQF
"the message header
let s:msgHead = '[QFGrep] ' 

"read user's highlighting setting, and define highlighting groups {{{1
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


"helper methods {{{1

"print err message in err highlighting{{{2
function! QFGrep#print_err_msg(errMsg)
  echohl QFGError
  echon s:msgHead . a:errMsg
  echohl None
endfunction


"print Highlighted info {{{2
function! QFGrep#print_HLInfo(msg)
  echohl QFGInfo
  echon s:msgHead .  a:msg
  echohl None
endfunction

"invoked by autocmd: init_origQF(){{{2
function! QFGrep#init_origQF()
  let s:origQF = []
endfunction

"invoked by autocmd:fill_origQF() {{{2
function! QFGrep#fill_origQF()
  let s:origQF = getqflist()
endfunction

"logic funtions {{{1

"QFGrep#copy_QuickFix(): make a copy of current QF {{{2
function! QFGrep#copy_QuickFix()
  "store original quickfix lists, so that later could be restored
  let s:origQF = len( s:origQF )>0? s:origQF : getqflist()
  let all = getqflist()
  if empty(all)
    call PrintErrMsg('Quickfix window is empty. Nothing could be grepped. ')
    return all
  endif
  return deepcopy(all)
endfunction


"do_grep(): filter logic {{{2
"if argument invert is 1, do invert match like grep -v
function! QFGrep#do_grep(pat, invert, cp) 
  "do validation
  if empty(a:pat)
    call QFGrep#print_err_msg("Empty pattern is not allowed")
    return
  endif

  try
    for d in a:cp
      if (!a:invert)
        if ( bufname(d['bufnr']) !~ a:pat && d['text'] !~ a:pat)
          call remove(a:cp, index(a:cp,d))
        endif
      else " here do invert matching
        if (bufname(d['bufnr']) =~ a:pat || d['text'] =~ a:pat)
          call remove(a:cp, index(a:cp,d))
        endif
      endif
    endfor
    call setqflist(a:cp)
    call QFGrep#print_HLInfo(len(a:cp) . ' entries in Grep result.')
  catch /^Vim\%((\a\+)\)\=:E/
    call QFGrep#print_err_msg('Pattern invalid')
  endtry
endfunction

" grep_QuickFix(): grep QF, get pattern from userinput {{{2
"if argument invert is 1, do invert match like grep -v
function! QFGrep#grep_QuickFix(invert)
  "get cp of QF
  let cp = QFGrep#copy_QuickFix()
  if empty(cp)
    call QFGrep#print_err_msg('Quickfix window is empty. Nothing could be grepped. ')
    return
  endif
  call inputsave()
  echohl QFGPrompt
  let pat = input( s:msgHead . 'Pattern' . (a:invert?' (Invert-matching):':':'))
  echohl None
  call inputrestore()
  "clear the cmdline
  exec 'redraw' 

  call QFGrep#do_grep(pat, a:invert, cp)
endfunction

"grep_QuickFix_with_pattern(): do grep on quickfix with pattern as argument{{{2
function! QFGrep#grep_QuickFix_with_pattern( pat, invert )
  let cp = QFGrep#copy_QuickFix()
  if empty(cp)
    call QFGrep#print_err_msg('Quickfix window is empty. Nothing could be grepped. ')
    return
  endif

  call QFGrep#do_grep(a:pat, a:invert, cp)
endfunction

"restore quickfix items since last qf command{{{2
function! QFGrep#restore_QuickFix()
  if len(s:origQF) > 0
    call setqflist(s:origQF)
    call QFGrep#print_HLInfo('Quickfix entries restored.')
  else
    call QFGrep#print_err_msg("Nothing can be restored")
  endif
endfunction

" vim: ts=2:tw=80:shiftwidth=2:tabstop=2:fdm=marker:expandtab:
