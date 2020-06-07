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
function! boxcar#make(...)

  " set defaults and check params 
  let l:y = a:0 > 0 ? a:1 : 3 
  let l:x = a:0 > 1 ? a:2 : 3 

  " get code-block
  let l:cp = getcurpos()
  let l:row = l:cp[1]
  let l:col = l:cp[4]
  try
    let [l:start, l:end, l:block] = boxcar#block#get(l:row, '```')
  catch
    echohl v:exception
    return 1
  endtry

  " get other boxes
  try
    let l:corners = s:get_corners(l:block)
  catch
    echohl v:exception.'::'.v:throwpoint
    return 1
  endtry

  " if in a box throw
  let l:cur_box_ind = s:in_box(l:corners, [l:row, l:col])
  if l:cur_box_ind != -1
    echohl 'cannot put box in box'
    return 1
  endif

  " get potentially affected boxes and premove required lines
  call s:fix_lines(l:corners, l:start, [l:row, l:col], 3, 3)

  " add new box
  let l:box_components =  ['┏━┓','┃ ┃','┗━┛']
  let l:i = l:row
  for b in l:box_components

    " add extra line if necessary
    if l:i == l:end
      call append(l:i-1, repeat(' ', l:col-1))
      " end moves down
      let l:end += 1
    " add extra width to line if necessary
    else
      let l:l = getline(l:i)
      call setline(l:i, l:l
            \ .repeat(' ', (l:col-1) - strchars(l:l)))
    endif

    " add box components
    call setline(l:i, join(extend(
          \ split(getline(l:i), '\zs'), 
          \ split(b, '\zs'),
          \ l:col - 1
          \ ), ''))

    " next line
    let l:i += 1
  endfor

  " put cursor on box
  call cursor(l:row+1, l:col+2)

  " resize if necessary
  if l:y > 3 || l:x > 3
    call boxcar#box#resize(l:y-3, l:x-3, 0)
  endif

  " insert mode TODO only apply in choo-choo mode, make -> BoxcarOn -> insert
  " execute 'normal! a'
endfunction
