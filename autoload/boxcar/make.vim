""
" @public
" Create a {y} by {x} unicode box, putting the top-left corner under the cursor's
" current position. If BoxcarOn is enabled the cursor will be placed inside
" the box.
" Ex: 
" >
"   ```                          ```
"   █ <━━━━┓                     ┏━┓ 
"   ```    ┃              ┏━━━>  ┃█┃   cursor is inside box
"   with cursor here      ┃      ┗━┛
"    call :BoxcarMake ━━━━┛      ```
" <
" If called without parameters, the defaults are 3 and 3, which area also the
" minimum values for this function. If called with only
" 1 parameter the default for the {x} will be 3. Must be called inside a
"   code-fence; see @function(boxcar#block#get).
function! boxcar#make#box(...)

  " set defaults and check params 
  let y = a:0 > 0 ? a:1 : 3 
  let x = a:0 > 1 ? a:2 : 3 

  " get code-block
  let cp = getcurpos()
  let row = cp[1]
  let col = cp[4]
  try
    let [start, end, block] = boxcar#block#get(row, '```')
  catch
    echohl v:exception
    return 1
  endtry

  " get other boxes
  try
    let corners = boxcar#get#corners(block)
  catch
    echohl v:exception.'::'.v:throwpoint
    return 1
  endtry

  " if in a box throw
  let cur_box_ind = s:in_box(corners, [row, col])
  if cur_box_ind != -1
    echohl 'cannot put box in box'
    return 1
  endif

  " get potentially affected boxes and premove required lines
  call s:fix_lines(corners, start, [row, col], 3, 3)

  " add new box
  let box_components =  ['┏━┓','┃ ┃','┗━┛']
  let i = row
  for b in box_components

    " add extra line if necessary
    if i == end
      call append(i-1, repeat(' ', col-1))
      " end moves down
      let end += 1
    " add extra width to line if necessary
    else
      let l = getline(i)
      call setline(i, l
            \ .repeat(' ', (col-1) - strchars(l)))
    endif

    " add box components
    call setline(i, join(extend(
          \ split(getline(i), '\zs'), 
          \ split(b, '\zs'),
          \ col - 1
          \ ), ''))

    " next line
    let i += 1
  endfor

  " put cursor on box
  call cursor(row+1, col+2)

  " resize if necessary
  if y > 3 || x > 3
    call boxcar#box#resize(y-3, x-3, 0)
  endif

  " insert mode TODO only apply in choo-choo mode, make -> BoxcarOn -> insert
  " execute 'normal! a'
endfunction
