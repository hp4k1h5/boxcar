""
" @public
function! boxcar#block#get(cp, marker)
  let l:st = a:cp[1]
  while l:st > 0
    if stridx(getline(l:st), a:marker) ==# 0
      break
    endif
    let l:st-=1
  endwhile
  let l:en = a:cp[1]+1
  while l:en <= line('$')
    if stridx(getline(l:en), a:marker) ==# 0
      break
    endif
    let l:en+=1
  endwhile
  
  if ! l:st || l:en > line('$')
    throw 'cursor is not inside a '.a:marker.' code fence'
  endif
  return [l:st, l:en, getline(l:st, l:en)]
endfunction
