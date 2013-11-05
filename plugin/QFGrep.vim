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
if exists("g:loaded_QFGrep") || &cp
  finish
endif

let s:version       = "1.0.3"

let g:loaded_QFGrep = 1

"mappings
let g:QFG_Grep      = !exists('g:QFG_Grep')? '<Leader>g' : g:QFG_Grep
let g:QFG_GrepV     = !exists('g:QFG_GrepV')? '<Leader>v' : g:QFG_GrepV
let g:QFG_Restore   = !exists('g:QFG_Restore')? '<Leader>r' : g:QFG_Restore


"autocommands 
function! <SID>FTautocmdBatch()
  command! QFGrep    call QFGrep#GrepQuickFix(0)  "invert flag =0
  command! QFGrepV   call QFGrep#GrepQuickFix(1)  "invert flag =1
  command! QFRestore call QFGrep#RestoreQuickFix()
  "mapping
  execute 'nnoremap <buffer><silent>' . g:QFG_Grep    . ' :QFGrep<cr>'
  execute 'nnoremap <buffer><silent>' . g:QFG_GrepV   . ' :QFGrepV<cr>'
  execute 'nnoremap <buffer><silent>' . g:QFG_Restore . ' :QFRestore<cr>'

endfunction



augroup QFG
  au!
  autocmd QuickFixCmdPre * call QFGrep#init_origQF()
  autocmd QuickFixCmdPost * call QFGrep#fill_origQF()
  autocmd FileType qf call <SID>FTautocmdBatch()
augroup end

command! QFGrepVersion echo "QFGrep Version: " . s:version

" vim: ts=2:tw=80:shiftwidth=2:tabstop=2:fdm=marker:expandtab:
