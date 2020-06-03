""
" =============================================================================
" What Is This: boxcar
" File: plugin/boxcar.vim
" Author: bob <robertwalks@gmail.com>
" Last Change: 2020/06/03
" Version: v0.1
" Help: see README.md and doc/boxcar.txt
" Thanks:
" ChangeLog:
"     0.0  : init (2020/05/10)
"     0.1  : init (2020/06/03)

command -nargs=? BoxcarOn call boxcar#on()
command -nargs=? BoxcarOff call boxcar#off()
command -nargs=? BoxcarMake call boxcar#box#make()
command -nargs=? BoxcarResize call boxcar#box#resize(<f-args>)

function s:box_time()
  call timer_start(0, {-> boxcar#box#resize(0,1,1)})
endfunction

function! boxcar#on()
  if !exists('#Boxcar#InsertCharPre')
    autocmd!
    augroup Boxcar
      autocmd!
      autocmd InsertCharPre *  call s:box_time()
    augroup END
  endif
endfunction

function! boxcar#off()
  augroup Boxcar
    autocmd!
  augroup END
endfunction
