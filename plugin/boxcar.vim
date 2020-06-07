""
" =============================================================================
" What Is This: boxcar
" File: plugin/boxcar.vim
" Author: bob <robertwalks@gmail.com>
" Last Change: 2020/06/03
" Version: v0.2
" Help: see README.md and doc/boxcar.txt
" Thanks:
" ChangeLog:
"      v0.1  : improvements (2020/06/06)
"    v0.0_1  : init (2020/06/03)
"      v0.0  : init (2020/05/10)

""
" @section Introduction, intro
" @plugin(name) is a plugin for creating unicode boxes. All boxcar operations
" are assumed to take place inside of a markdown code-fence. The basic
" operations of this plugin include creating and resizing boxes. While more
" functionality is being added, try to keep in mind two vim commands that will
" help a lot: 1) Replace mode, i.e. type 'R' in normal mode, and 2) <Ctrl-v>,
" which can perform box-like cut and paste. 
"
" For some examples see vader test files.


""
" Enables auto-grow as you type inside a box. Call 'BoxcarOff' to
" disable  
" ! hitting enter will not work as expected
command -nargs=? BoxcarOn call boxcar#on()

""
" BoxcarOff disables auto-grow as you type mode.
command -nargs=0 BoxcarOff call boxcar#off()

""
" Create a new 3x3 box whose top-left corner is under the cursor
command -nargs=* BoxcarMake call boxcar#box#make(<f-args>)

""
" Resize a box underneath the cursor by {y} lines and {x} cols. Cursor must be
" fully inside, i.e. not on a border.
"
" Ex: BoxcarResize 4 3 
"
" resizes the box under the cursor by 4 lines and 3 columns
command -nargs=* BoxcarResize call boxcar#box#resize(<f-args>, 0)

function s:box_time()
  call timer_start(0, {-> boxcar#box#resize(0,1,1)})
endfunction

function! boxcar#on()
  echom '🚂🚃🚃'
  if !exists('#Boxcar#InsertCharPre')
    autocmd!
    augroup Boxcar
      autocmd!
      autocmd InsertCharPre *  call s:box_time()
    augroup END
  endif
endfunction

function! boxcar#off()
  echom '🚥🚉'
  augroup Boxcar
    autocmd!
  augroup END
endfunction
