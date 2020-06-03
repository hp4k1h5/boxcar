""
" =============================================================================
" What Is This: boxcar
" File: plugin/boxcar.vim
" Author: bob <robertwalks@gmail.com>
" Last Change:2020/05/11
" Version: 0.0
" Help: see README.md and doc/boxcar.txt
" Thanks:
" ChangeLog:
"     0.0  : init (2020/05/10)

command -nargs=? BoxcarOn call boxcar#on()
command -nargs=? BoxcarOff call boxcar#off()
command -nargs=? BoxcarMake call boxcar#box#make()
command -nargs=? BoxcarResize call boxcar#box#resize(<f-args>)

function! boxcar#on()
  if !exists('#Boxcar#InsertCharPre')
    autocmd!
    augroup Boxcar
      autocmd!
      autocmd InsertCharPre *  call boxcar#box#resize(0, 1)
    augroup END
  endif
endfunction

function! boxcar#off()
  augroup Boxcar
    autocmd!
  augroup END
endfunction
