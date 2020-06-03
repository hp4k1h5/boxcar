" TODO add syntax ```boxcar that allows user to input a syntax to create boxes
" at compile time as opposed to dynamically as they type.
" i.e. 
" ```boxcar
" @s='a string inside a box'
" @t=header-title-and-the-text-comes-too
" #0x0[@t]t
" #10x0[@v]a
" #10x0[@v]b
" b->a
" -------
"  t
"       a
"
"  b
" -------
" ```
" would produce a box 10 chars wide with the text fitted inside.
" if the shortest word was too long, it would error dynamically but compile to
" a best fit approximation

""
" does this register ?
function! boxcar#box#make()abort
  let l:cp = getcurpos()
  try
    let [l:start, l:end, l:block] = boxcar#block#get(l:cp, '```')
  catch
    echoerr v:exception
    return 1
  endtry

  call append(l:cp[1]-1, ['┏━┓','┃ ┃','┗━┛'])
  " these numbers seem off
  call cursor(l:cp[1]+1, 4)
  " insert mode
  execute 'normal! a'
endfunction

function! boxcar#box#resize()
  try
    let [l:start, l:end, l:block] = boxcar#block#get(getcurpos(), '```')
  catch
    echoerr v:exception
    return 1
  endtry

  try
    let l:corners = s:get_corners(l:block)
    let l:cur_box_ind = s:in_box(l:corners)
  catch
    echoerr v:exception.'::'.v:throwpoint
    return 1
  endtry

  let l:keypress = getchar(0)
  call boxcar#box#inc(l:block, l:start, l:end, l:corners[l:cur_box_ind], 0, 1)
endfunction

function! boxcar#box#inc(block, start, end, box, y, x)

  let l:border_x = repeat('━', a:x)
  let l:blank_x = repeat(' ', a:x)
  let l:newline = '┃'. repeat(' ', a:box[1][1] - a:box[0][1]).'┃'

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
        \ split(l:blank_x, '\zs'), 
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
endfunction

function! box#dec(box, y, x)

endfunction

" get box corners
function s:get_corners(block)
  let l:corners = []
  let l:i = 0

  let l:tls = s:get_tls(a:block)
  if ! len(l:tls)
    throw 'no top-left corners'
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

  throw 'cursor '.l:y.':'.l:x.'not in box'
endfunction

au InsertCharPre * call boxcar#box#resize()
