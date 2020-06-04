""
" @public
" Create a 3x3 unicode box putting the top-left corner under the cursor's
" current position. The cursor will be placed inside the box.
" Ex: 
" >
" ```
"   ┏━┓
"   ┃ ┃
"   ┗━┛
" ```
" <
" Must be called inside a code-fence. See @function(boxcar#block#get).
function! boxcar#box#make()

  " get code-block
  let [l:line_nr, l:str_ind] = getpos('.')[1:2]
  try
    let [l:start, l:end, l:block] = boxcar#block#get(l:line_nr, '```')
  catch
    echoerr v:exception
  endtry

  " get other boxes
  try
    let l:corners = s:get_corners(l:block)
  catch
    echoerr v:exception.'::'.v:throwpoint
    return 1
  endtry

  " if in a box throw
  let l:cur_box_ind = s:in_box(l:corners)
  if l:cur_box_ind != -1
    throw 'cannot put box in box'
  endif

  call append(l:line_nr-1, ['┏━┓','┃ ┃','┗━┛'])
  " these numbers seem off
  call cursor(l:line_nr+1, 4)

  " insert mode TODO only apply in choo-choo mode, make -> BoxcarOn -> insert
  " execute 'normal! a'
endfunction

function! boxcar#box#resize(y, x, live)
  try
    let [l:start, l:end, l:block] = boxcar#block#get(getpos('.'), '```')
  catch
    echoerr v:exception
    return 1
  endtry

  let l:corners = s:get_corners(l:block)
  if ! len(l:corners)
    echoerr 'no top-left corners'
    return 1
  endif

  let l:cur_box_ind = s:in_box(l:corners)
  if l:cur_box_ind == -1
    throw 'cursor '.l:y.':'.l:x.'not in box'
  endif

  call boxcar#box#inc(l:block, l:start, l:end, l:corners[l:cur_box_ind], a:y, a:x, a:live)
endfunction

function! boxcar#box#inc(block, start, end, box, y, x, live)
  let l:cp = getpos('.')
  let l:border_x = repeat('━', a:x)
  let l:blank_x = repeat(' ', a:x)
  let l:newline = repeat(' ', a:box[0][1]).'┃'. 
        \ repeat(' ', a:box[1][1] - (a:box[0][1] + 1) + a:x).'┃'

  let l:box_start_y = a:start + a:box[0][0] 
  let l:box_end_y = a:start + a:box[2][0]
  let l:box_end_x = a:box[1][1]

  " extend top border, off by is from array-to-page mapping
  call setline(l:box_start_y,
        \ join(extend( 
        \ split(a:block[a:box[0][0]], '\zs'), 
        \ split(l:border_x, '\zs'), 
        \ l:box_end_x), ''))

  " extend content area
  let l:i = l:box_start_y + 1
  for l in a:block[a:box[0][0]+1: a:box[2][0]]
    call setline(l:i,
        \ join(extend( 
        \ split(l, '\zs'), 
        \ l:i == l:cp[1] && a:live ? [''] : split(l:blank_x, '\zs'), 
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

  let l:i = a:y
  while l:i
    call append(getcurpos()[1], l:newline)
    " next newline
    let l:i -= 1
  endwhile
endfunction


function! box#dec(box, y, x)
endfunction


" get box corners
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

" returns [y,x] coordinate pairs of all top-left corners in {block}
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

" returns the index of the {boxes} list the cursor is in or -1 if the cursor
" is not inside one
function s:in_box(boxes)

  let l:cp = getcurpos()
  let l:y = l:cp[1]-1
  let l:x = l:cp[4]-1
  let l:i = 0
  for b in a:boxes
    if l:y > b[0][0] && l:y < b[3][0]
          \ && l:x > b[0][1] && l:x < b[1][1]
      return l:i
    endif
    let l:i += 1
  endfor

  return -1
endfunction
