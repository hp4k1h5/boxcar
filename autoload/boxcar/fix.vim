" Corrects lines in {boxes} that intersect with horizontal lines on the x axis
" between 
function boxcar#fix#lines(boxes, start, cp, y, x)

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
