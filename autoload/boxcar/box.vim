"" 
" TODO: replace me
" ```
"
" ```
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
    let l:block = s:get_block(l:cp, '```')
  catch /.*/
    echoerr v:throwpoint.':'.v:exception
  endtry

  echom "hi"
  " let l:boxes = s:get_boxes(l:cp)
endfunction

function! s:get_block(cp, marker)
  let l:st = a:cp[1]
  while l:st > 0
    if stridx(getline(l:st), a:marker) > -1
      break
    endif
    let l:st-=1
  endwhile
  let l:en = a:cp[1]
  while l:en <= line('$')
    if stridx(getline(l:en), a:marker) > -1
      break
    endif
    let l:en+=1
  endwhile
  if l:st == -1 || l:en > line('$')
    throw 'cursor is not inside a ``` code fence'
  endif
  return [l:st, l:en]
endfunction

""
" gets boxes
function! s:get_boxes(cp)abort
  echom "hi"
  " echom join(a:cp, ' ')
endfunction


" ```
