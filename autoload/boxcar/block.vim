""
" @public
" Get start and end lines of the code-block surrounding {line_nr}. Code block
" is composed of lines inside of a code-fence, composed of two {markers}.
" Default marker is the standard markdown ``` three backticks. Cursor must be
" **between** code-block markers, not on either. Throws if not inside.
function! boxcar#block#get(line_nr, marker)

  " look up
  let l:st = a:line_nr - 1
  while l:st > 0
    if getline(l:st) =~ '^'.a:marker
      break
    endif
    let l:st -= 1
  endwhile

  " look down
  let l:en = a:line_nr + 1
  while l:en <= line('$')
    if stridx(getline(l:en), a:marker) == 0
      break
    endif
    let l:en += 1
  endwhile
  
  if ! l:st || l:en > line('$')
    throw 'cursor is not inside a '.a:marker.' code fence'
  endif

  return [l:st, l:en, getline(l:st, l:en)]
endfunction
