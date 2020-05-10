" TODO replace me


function! boxcar#box#make()
  let l:block = s:get_block()
endfunction

function! s:get_block()
  let l:cp = getcurpos()
  let l:st = l:cp[1]
  while l:st > 0
    if stridx(getline(l:st), '```') > -1
      break
    endif
    let l:st-=1
  endwhile
  let l:en = l:cp[1]
  while l:en <= line('$')
    if stridx(getline(l:en), '```') > -1
      break
    endif
    let l:en+=1
  endwhile
  echom l:st.' ; '.l:en

endfunction
