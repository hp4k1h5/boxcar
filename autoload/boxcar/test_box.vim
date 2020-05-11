" ``` 
" leave this code block and all lines above this one here for the following
" test
" ```
call cursor(2,1)
let l = [1, 3]
call assert_equal(l, [1, 3])
