" TODO replace me
" ```
"
" ```


function! boxcar#box#make()abort
  try
    let l:block = s:get_block('```')
  catch /.*/
    echoerr v:throwpoint.':'.v:exception
  endtry
endfunction

function! s:get_block(marker)
  let l:cp = getcurpos()
  let l:st = l:cp[1]
  while l:st > 0
    if stridx(getline(l:st), a:marker) > -1
      break
    endif
    let l:st-=1
  endwhile
  let l:en = l:cp[1]
  while l:en <= line('$')
    if stridx(getline(l:en), a:marker) > -1
      break
    endif
    let l:en+=1
  endwhile
  if l:st == -1 || l:en > getline('$')
    throw 'cursor is not inside a ``` code fence'
  endif
  return [l:st, l:en]
endfunction
