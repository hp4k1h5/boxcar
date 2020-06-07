""
" @public
" Resize the box the cursor is in by {y} rows and {x} columns. If {live} is
" true, the line under edit will not be padded out, to accomodate the newly
" inserted char. The y and x values are added from the cursor's current
" position. currently only works with positive numbers.
function! boxcar#resize#box(y, x, live)

  if a:y < 0 || a:x < 0 || a:live < 0 || a:live > 1
    throw 'bad arguments supplied please see docs'
  endif

  let cp = getcurpos()
  let cp = [cp[1], cp[4]]
  try
    let [start, end, block] = boxcar#block#get(cp[0], '```')
  catch
    echohl join(v:exception, '::')
    return 1
  endtry

  let corners = boxcar#get#corners(block)
  if ! len(corners)
    echohl 'no top-left corners'
    return 1
  endif

  let cur_box_ind = boxcar#in#box(corners, [cp[0]-start+1, cp[1]-a:live])
  if cur_box_ind == -1
    echohl 'cursor not in box'
    return 1
  endif
  let cur_box = corners[cur_box_ind]

  " get potentially affected boxes and premove required lines
  call boxcar#fix#lines(corners, start, 
        \ [cur_box[0][0]+start, cp[1]],
        \ (cur_box[2][0] - cur_box[0][0] + 1), a:x)

  call s:increment(block, start, end, cp, cur_box, a:y, a:x, a:live)

endfunction


" add empty rows {y} and columns {x} to a {box} beginning at cursor
" location {cp}. If {live} is true, skip line extension for cp[1].
function s:increment(block, start, end, cp, box, y, x, live)

  " set box elements
  let border_x = split(repeat('━', a:x), '\zs')
  let blank_x = split(repeat(' ', a:x), '\zs')

  " set constants
  let box_start_y = a:start + a:box[0][0] 
  let box_end_y = a:start + a:box[2][0]
  let box_end_x = a:box[1][1]

  " extend top border
  call setline(box_start_y,
        \ join(extend( 
        \ split(a:block[a:box[0][0]], '\zs'), 
        \ border_x,
        \ box_end_x), ''))

  " extend content area, off-by is from array-to-page mapping. Skip extension
  " when typing live, as character input will extend line by itself 
  let i = box_start_y + 1
  for l in a:block[a:box[0][0]+1: a:box[2][0]]
    call setline(i, join(extend( 
        \ split(l, '\zs'), 
        \ i == a:cp[0] && a:live ? [''] : blank_x,
        \ box_end_x), ''))
    " next line
    let i += 1
  endfor

  " extend bottom border
  call setline(box_end_y,
        \ join(extend( 
        \ split(a:block[a:box[2][0]], '\zs'), 
        \ border_x,
        \ box_end_x), ''))

  " reevaluate block and boxes after extending right
  let [start, end, block] = boxcar#block#get(a:cp[0], '```')
  let corners = boxcar#get#corners(block)
  let cur_box_ind = boxcar#in#box(corners, [a:cp[0]-a:start+1, a:cp[1]-a:live])
  let box = corners[cur_box_ind]

  " add y values 
  let i = a:cp[0]
  let end = a:end
  let stop = i + a:y
  while i < stop
    " add newlines if at block end
    " if i-1 >= end
    "   call append(i, repeat(' ', box[1][1] + 1))
    "   let end += 1
    " endif

    if i < a:end 
          \ && box[0][1] > 0 
          \ && len(a:block[i-a:start]) >= box[0][1]
      let rep_start =  join(split(block[i - a:start], '\zs')[:box[0][1]-1], '')
      let rep_end = join(split(a:block[i - a:start], '\zs')[box[1][1] + 1:], '')
    else
      let rep_start = repeat(' ', box[0][1])
      let rep_end = ''
    endif
    call append(i-1, 
          \ rep_start.'┃'
          \ .repeat(' ', box[1][1] - box[0][1] - 1)
          \ .'┃'.rep_end)

    let i += 1
  endwhile
endfunction


" remove rows {y} and columns {x} from {box}
function! s:decrement(box, y, x)
endfunction
