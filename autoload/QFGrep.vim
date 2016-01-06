" QFGrep  : a vim plugin to filter Quickfix entries
" Author  : Kai Yuan <kent.yuan@gmail.com>
" License: {{{1
"Copyright (c) 2013-2016 Kai Yuan
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


"return true if the current window is a location list{{{2
function! QFGrep#is_loc_list()
  " it is necessary to check the current filename as a location list may have no
  " elements (e.g.: lgrep return no matches)
  redir => l:filename
  silent file
  redir END

  if !empty(getloclist(0)) || l:filename =~ 'Location List'
    return 1
  endif
  return 0
endfunction

"return the contents of quickfix/location list{{{2
function! QFGrep#get_list()
  " if the contents are being retrieved they are probably going to be changed;
  " store the original, so that later it could be restored
  if QFGrep#is_loc_list()
    let current = getloclist(0)
    if !exists('b:origLL') || !exists('b:lastLL') || current != b:lastLL
      let b:origLL = current
    endif
  else
    let current = getqflist()
    if !exists('s:origQF') || !exists('s:lastQF') || current != s:lastQF
      " Quickfix requires a g:var/s:var as it can be accessed from different
      " tabpages
      let s:origQF = current
    endif
  endif

  return current
endfunction

"change the contents of quickfix/location list{{{2
function! QFGrep#set_list(list)
  " save the last modification, so we can detect if the quickfix has new content
  if QFGrep#is_loc_list()
    "save window title, so that after setting qf, we can restore the title
    if exists("w:quickfix_title")
      let l:title_kept = w:quickfix_title
    endif

    call setloclist(0, a:list)
    let b:lastLL = a:list
    silent doautocmd QuickFixCmdPost lqfgrep
  else
    call setqflist(a:list)
    let s:lastQF = a:list
    silent doautocmd QuickFixCmdPost qfgrep
  endif
  "restore the window title if there was one
  if exists("l:title_kept")
    if l:title_kept !~ '\V'.s:msgHead
      let l:title_kept = s:msgHead.l:title_kept
    endif
    let w:quickfix_title = l:title_kept
  endif
endfunction

"get original contents of quickfix/location list {{{2
function! QFGrep#get_orig()
  if QFGrep#is_loc_list()
    return exists('b:origLL') ? b:origLL : []
  else
    return exists('s:origQF') ? s:origQF : []
  endif
endfunction


"logic funtions {{{1

"QFGrep#copy_QuickFix(): make a copy of current QF {{{2
function! QFGrep#copy_QuickFix()
  let all = QFGrep#get_list()
  if empty(all)
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

  let line = getline(1, '$')
  try
    for i in reverse(range(len(line)))
      if (!a:invert)
        if (line[i] !~ a:pat)
          call remove(a:cp, i)
        endif
      else " here do invert matching
        if (line[i] =~ a:pat)
          call remove(a:cp, i)
        endif
      endif
    endfor
    call QFGrep#set_list(a:cp)
    call QFGrep#print_HLInfo(len(a:cp) . ' entries in Grep result.')
  catch /^Vim\%((\a\+)\)\=:E/
    call QFGrep#print_err_msg('Pattern invalid')
  endtry
endfunction

" grep_QuickFix(): grep QF, get pattern from userinput {{{2
"if argument invert is 1, do invert match like grep -v
function! QFGrep#grep_QuickFix(invert)
  if &buftype != 'quickfix'
    call QFGrep#print_err_msg('commands work only in Quickfix/location-list buffer.')
    return
  endif
  "get cp of QF
  let cp = QFGrep#copy_QuickFix()
  if empty(cp)
    call QFGrep#print_err_msg('Quickfix/location-list window is empty. Nothing could be grep-ed. ')
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
    call QFGrep#print_err_msg('Quickfix/location-list window is empty. Nothing could be grep-ed. ')
    return
  endif

  call QFGrep#do_grep(a:pat, a:invert, cp)
endfunction

"restore quickfix items since last qf command{{{2
function! QFGrep#restore_QuickFix()
  if &buftype != 'quickfix'
    call QFGrep#print_err_msg('commands work only in Quickfix/location-list buffer.')
    return
  endif
  let orig = QFGrep#get_orig()
  if !empty(orig)
    call QFGrep#set_list(orig)
    call QFGrep#print_HLInfo('Original entries are restored.')
  else
    call QFGrep#print_err_msg("Nothing can be restored")
  endif
endfunction

" vim: ts=2:tw=80:shiftwidth=2:tabstop=2:fdm=marker:expandtab:
