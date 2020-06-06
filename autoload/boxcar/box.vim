""
" @public
" Create a 3x3 unicode box, putting the top-left corner under the cursor's
" current position. If BoxcarOn is enabled the cursor will be placed inside
" the box.
" Ex: 
" >
"   ```                          ```
"   █ <━━━━┓                     ┏━┓  if BoxcarOn is enabled, cursor
"   ```    ┃              ┏━━━>  ┃█┃   is inside box in insert mode
"   with cursor here      ┃      ┗━┛
"    call :BoxcarMake ━━━━┛      ```
" <
" Must be called inside a code-fence; see @function(boxcar#block#get).
function! boxcar#box#make()

  " get code-block
  let l:cp = getcurpos()
  let l:line_nr = l:cp[1]
  let l:col = l:cp[4]
  try
    let [l:start, l:end, l:block] = boxcar#block#get(l:line_nr, '```')
  catch
    echoerr v:exception
    return 1
  endtry

  " get other boxes
  try
    let l:corners = s:get_corners(l:block)
  catch
    echoerr v:exception.'::'.v:throwpoint
    return 1
  endtry

  " if in a box throw
  let l:cur_box_ind = s:in_box(l:corners, [l:line_nr, l:col])
  if l:cur_box_ind != -1
    echoerr 'cannot put box in box'
    return 1
  endif

  " get potentially affected boxes and premove required lines
  call s:fix_lines(l:corners, l:start, [l:line_nr, l:col], 3, 3)

  " add new box
  let l:box_components =  ['┏━┓','┃ ┃','┗━┛']
  let l:i = l:line_nr
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
  call cursor(l:line_nr+1, l:col+2)

  " TODO resize if necessary

  " insert mode TODO only apply in choo-choo mode, make -> BoxcarOn -> insert
  " execute 'normal! a'
endfunction


""
" @public
" Resize the box the cursor is in by {y} rows and {x} columns. If {live} is
" true, the line under edit will not be padded out, to accomodate the newly
" inserted char. The y and x values are added from the cursor's current
" position. currently only works with positive numbers.
function! boxcar#box#resize(y, x, live)

  if a:y < 0 || a:x < 0 || a:live < 0 || a:live > 1
    throw 'bad arguments supplied please see docs'
  endif

  let l:cp = getcurpos()
  let l:cp = [l:cp[1], l:cp[4]]
  try
    let [l:start, l:end, l:block] = boxcar#block#get(l:cp[0], '```')
  catch
    echoerr join(v:exception, '::')
    return 1
  endtry

  let l:corners = s:get_corners(l:block)
  if ! len(l:corners)
    echoerr 'no top-left corners'
    return 1
  endif

  let l:cur_box_ind = s:in_box(l:corners, [l:cp[0]-l:start+1, l:cp[1]-a:live])
  if l:cur_box_ind == -1
    echoerr 'cursor y'.l:cp[0].':x'.l:cp[1].'not in box'
    return 1
  endif
  let l:cur_box = l:corners[l:cur_box_ind]

  " get potentially affected boxes and premove required lines
  call s:fix_lines(l:corners, l:start, 
        \ [l:cur_box[0][0]+l:start, l:cp[1]],
        \ (l:cur_box[2][0] - l:cur_box[0][0] + 1), a:x)

  call s:increment(l:block, l:start, l:cp, l:cur_box, a:y, a:x, a:live)
endfunction


" add empty rows {y} and columns {x} to a {box} beginning at cursor
" location {cp}. If {live} is true, skip line extension for cp[1].
function s:increment(block, start, cp, box, y, x, live)

  " set box elements
  let l:border_x = repeat('━', a:x)
  let l:blank_x = repeat(' ', a:x)
  let l:newline = repeat(' ', a:box[0][1]).'┃'. 
        \ repeat(' ', a:box[1][1] - (a:box[0][1] + 1) + a:x).'┃'

  " set constants
  let l:box_start_y = a:start + a:box[0][0] 
  let l:box_end_y = a:start + a:box[2][0]
  let l:box_end_x = a:box[1][1]

  " extend top border
  call setline(l:box_start_y,
        \ join(extend( 
        \ split(a:block[a:box[0][0]], '\zs'), 
        \ split(l:border_x, '\zs'), 
        \ l:box_end_x), ''))

  " extend content area, off-by is from array-to-page mapping. Skip extension
  " when typing live, as character input will extend line by itself 
  let l:i = l:box_start_y + 1
  for l in a:block[a:box[0][0]+1: a:box[2][0]]
    call setline(l:i, join(extend( 
        \ split(l, '\zs'), 
        \ l:i == a:cp[0] && a:live ? [''] : split(l:blank_x, '\zs'), 
        \ l:box_end_x), ''))
    " next line
    let l:i += 1
  endfor

  " set bottom border
  call setline(l:box_end_y,
        \ join(extend( 
        \ split(a:block[a:box[2][0]], '\zs'), 
        \ split(l:border_x, '\zs'), 
        \ l:box_end_x), ''))

  " add y values !! wip
  " let l:i = a:y
  " while l:i
  "   call append(getcurpos()[1], l:newline)
  "   " next newline
  "   let l:i -= 1
  " endwhile
endfunction


" remove rows {y} and columns {x} from {box}
function! s:decrement(box, y, x)
endfunction


" Returns a list of box corners inside {block}. Each returned box has 4
" corners in the following order [tl, tr, bl, br]. Each corner is a list of
" [y, x] zero-indexed pairs, relative to the {block}, not the page.
function s:get_corners(block)
  let l:corners = []
  let l:i = 0

  let l:tls = s:get_tls(a:block)
  if ! len(l:tls)
    return l:tls
  endif

  " iterate over corners and check each for full box
  for tl in l:tls
    let l:maybe_box = []
    " let unibox = ['━','┃','┏','┓','┗','┛']
  
    " find connected top-right or throw
    let l:ci = tl[1] + 1
    " iterate over chars in line from tl corner
    for c in split(a:block[tl[0]], '\zs')[l:ci:]
      if c ==# '┓'
        " add top-left and top-right to maybe_box
        call extend(l:maybe_box, [tl, [tl[0], l:ci]])
        break
      elseif c !=# '━'
        throw 'disconnected top right: '.c.' .. x-index: '.l:ci
      endif
      " next char
      let l:ci += 1
    endfor

    " find connected bottom-left or throw
    let l:blyi = tl[0] + 1
    for l in a:block[l:blyi:]
      let l:c = split(l, '\zs')[tl[1]]
      if l:c ==# '┗'
        " add bottom-leftto maybe_box
        call add(l:maybe_box, [l:blyi, tl[1]])
        break
      elseif l:c !=# '┃'
        throw 'disconnected bottom left: '.l:c.' .. y-index: '.l:blyi
      endif

      " next line
      let l:blyi += 1
    endfor

    " find connected bottom-right or throw
    let l:ci = tl[1] + 1
    for c in split(a:block[l:blyi], '\zs')[l:ci:]
      if c ==# '┛' 
        call add(l:maybe_box, [l:blyi, l:ci])
        break
      elseif c !=# '━'
        throw 'disconnected bottom right'
      endif

      " next char
      let l:ci += 1
    endfor

    " todo check tr -br connection
    " add box to corners
    call add(l:corners, l:maybe_box)
  endfor

  return l:corners
endfunction


" Returns a list of [y, x] coordinate pairs of all top-left corners in {block}
function s:get_tls(block)
  let l:tls = []
  let l:li = 0
  for l in a:block
    let l:ci = 0
    " split each string on char
    for c in split(l, '\zs')
      if c ==# '┏'
        call add(l:tls, [l:li, l:ci])
      endif
      let l:ci += 1
    endfor
    let l:li += 1
  endfor
  return l:tls
endfunction


" Returns the index of the box in {boxes} that the cursor is in, or -1 if the
" cursor is not inside a box
function s:in_box(boxes, cp)

  let l:y = a:cp[0]-1
  let l:x = a:cp[1]-1
  let l:i = 0
  for b in a:boxes
    if l:y > b[0][0] && l:y < b[2][0]
          \ && l:x > b[0][1] && l:x < b[1][1]
      return l:i
    endif
    let l:i += 1
  endfor

  return -1
endfunction


" Corrects lines in {boxes} that intersect with horizontal lines on the x axis
" between 
function s:fix_lines(boxes, start, cp, y, x)

  let l:lines_to_fix = {}
  " get set of lines affected by operation, mapped to block
  let l:b_set = range(a:cp[0] - a:start, a:cp[0] + a:y  - a:start-1)

  for b in a:boxes

    " skip left boxes and down boxes
    if b[0][1] < a:cp[1] - 1 ||
          \ b[0][0] > a:cp[0] - a:start + a:y
      continue
    endif

    " get set of lines a box touches
    let l:a_set = range(b[0][0], b[2][0])
    " find boxes that touch
    for a in l:a_set
      if match(l:b_set, a) > -1
        " find lines that don't
        for aa in l:a_set
          if match(l:b_set, aa) == -1
            let l:lines_to_fix[a:start + aa] = 1
          endif
        endfor
        " next box
        break
      endif
    endfor
  endfor

  " fix lines that not otherwise moved by operation
  for k in keys(l:lines_to_fix)
    call setline(k, join(extend(
          \ split(getline(k), '\zs'),
          \ repeat([' '], a:x), a:cp[1]-1), ''))
  endfor
endfunction

" function s:fix_cols(boxes, start, fix_start, fix_end, line, n)
"   let l:cols_to_fix
" endfunction
