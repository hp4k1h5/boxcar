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

""
" @public
" find all boxes inside code {block}, a list of lines inside a code fence
function! boxcar#box#get_all(block)
  let l:corners = s:get_corners(a:block)
  return l:corners
endfunction

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
    let l:ci = tl[1]
    for c in a:block[tl[0]][tl[1]:]
      if c ==# '┓'
        " add top-left and top-right to maybe_box
        call extend(l:maybe_box, [tl, [tl[0], l:ci]])
        break
      elseif c !=# '━'
        throw 'disconnected top'
      endif
      " next char
      let l:ci += 1
    endfor

    "find connected bottom-left or throw
    let l:blyi
    for l in a:block
      if l[tl[1]] ==# '┗'
        " add bottom-leftto maybe_box
        call add(l:maybe_box, [l:blyi, tl[1]])
        break
      elseif l[tl[1]] !=# '┃'

      endif
      let l:blyi += 1
    endfor

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
    for c in l
      if c ==# '┏'
        call add(l:tls, [l:li, l:ci])
      endif
      let l:ci += 1
    endfor
    let l:li += 1
  endfor
  return l:tls
endfunction
