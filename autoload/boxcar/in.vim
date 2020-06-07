" Returns the index of the box in {boxes} that the cursor {cp} is in, or -1 if
" the cursor is not inside a box. {cp} is a [row, col] list.
function boxcar#in#box(boxes, cp)

  let y = a:cp[0]-1
  let X = a:cp[1]-1
  let i = 0
  for b in a:boxes
    if y > b[0][0] && y < b[2][0]
          \ && X > b[0][1] && X < b[1][1]
      return i
    endif
    let i += 1
  endfor

  return -1
endfunction


