" QFGrep  : a vim plugin to filter Quickfix entries
" Author  : Kai Yuan <kent.yuan@gmail.com>
" License: {{{
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
" }}}
if exists("g:loaded_QFGrep") || &cp
  finish
endif

let g:loaded_QFGrep = 1

let s:version       = "2.0.1"
command! QFGrepVersion echo "QFGrep Version: " . s:version


"mappings
nnoremap <silent><unique> <Plug>QFGrepG :call QFGrep#grep_QuickFix(0)<cr>
nnoremap <silent><unique> <Plug>QFGrepV :call QFGrep#grep_QuickFix(1)<cr>
nnoremap <silent><unique> <Plug>QFRestore :call QFGrep#restore_QuickFix()<cr>

"autocommands 
function! <SID>FTautocmdBatch()
  command! -buffer -nargs=0 QFGrep     call QFGrep#grep_QuickFix(0)  "invert flag =0
  command! -buffer -nargs=0 QFGrepV    call QFGrep#grep_QuickFix(1)  "invert flag =1
  command! -buffer -nargs=0 QFRestore  call QFGrep#restore_QuickFix()

  command! -buffer -nargs=1 QFGrepPat  call QFGrep#grep_QuickFix_with_pattern("<args>",0)  "invert flag =0
  command! -buffer -nargs=1 QFGrepPatV call QFGrep#grep_QuickFix_with_pattern("<args>",1)  "invert flag =1

  "create mapping
  if !hasmapto('<Plug>QFGrepG','n')
    nmap <buffer> <Leader>g <Plug>QFGrepG
  endif
  if !hasmapto('<Plug>QFGrepV','n')
    nmap <buffer> <Leader>v <Plug>QFGrepV
  endif
  if !hasmapto('<Plug>QFRestore')
    nmap <buffer> <Leader>r <Plug>QFRestore
  endif

endfunction

augroup QFG
  au!
  autocmd FileType qf call <SID>FTautocmdBatch()
augroup end


" vim: ts=2:tw=80:shiftwidth=2:tabstop=2:fdm=marker:expandtab:
