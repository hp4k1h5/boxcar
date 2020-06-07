# boxcar
> a vim plugin to create and edit configurable unicode boxes
#### ! experimental and unstable
still very experimental and liable to have odd behaviors and [bugs](#bugs).
please see [CONTRIBUTING](.github/CONTRIBUTING.md) if you would like to help improve
this plugin.


```boxcar
                ┏━┓   ┏━┓
  ┏━━━━┓ ┏━━━━┓ ┃ ┃   ┃ ┃
  ┃    ┃ ┃    ┃ ┗━┛   ┗━┛
  ┗━━━━┛ ┃ ┏┓ ┃    ┏━┓
  ┏━━━━┓ ┃ ┗┛ ┃    ┃ ┃
  ┃    ┃ ┃    ┃ ┏━┓┗━┛ ┏━┓
  ┗━━━━┛ ┗━━━━┛ ┃ ┃    ┃ ┃
                ┗━┛    ┗━┛
```

### usage
call `:BoxcarMake` inside a markdown code-block i.e. inside a code-fence of
three back-ticks.  
```boxcar
    ```                          ```
    █ <━━━━┓                     ┏━┓
    ```    ┃              ┏━━━>  ┃█┃   cursor is inside box
    with cursor here      ┃      ┗━┛
     call :BoxcarMake ━━━━┛      ```
```

and then either resize the box with e.g. `:BoxcarResize 3 3` with your
cursor inside the box, or call `:BoxcarOn` and then start
typing inside a box in insert mode. Be aware that BoxcarOn requires the user
to be inside a box in order to type. To disable, call `:BoxcarOff`.

If you first resize a box to your desired size, you can type inside of it with
'Replace mode', by e.g. typing `R` in normal mode. Otherwise `BoxcarOn` allows
you to grow a box as large as you like, as you type. current behavior is not
smart enough to handle multiline yet, so its a bit of a manual process, of
`BoxcarResize {lines} {cols}` and 'Replace mode'.

#### Commands

:BoxcarOn                                                          *:BoxcarOn*
  Enables auto-grow as you type inside a box. Call 'BoxcarOff' to disable   !
  hitting enter will not work as expected

:BoxcarOff                                                        *:BoxcarOff*
  BoxcarOff disables auto-grow as you type mode.

:BoxcarMake                                                      *:BoxcarMake*
  Create a new 3x3 box whose top-left corner is under the cursor

:BoxcarResize {y} {x}                                          *:BoxcarResize*
  Resize a box underneath the cursor by {y} lines and {x} cols. Cursor must be
  fully inside, i.e. not on a border.

  Ex: BoxcarResize 4 3

  resizes the box under the cursor by 4 lines and 3 columns

### bugs
there are many, mostly related to resizing a box vertically when there are
other boxes around. It works ok, but for now, it's recommended to think top
down and left-right and try to ...square away... the top and left before
adding more boxes to the right and down.
