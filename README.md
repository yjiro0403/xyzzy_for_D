#README
�EBecause this program is not complated, it is updated some time.
�EIf you will help me to update this code, get in touch freely.

#Install
1. move "d-mode.l" to "xyzzy/lisp" or other directory
2. load "d-mode.l" on directory you moved

```lisp:site-init.l
;Add D-mode
(push "D:/xyzzy/lisp/d-mode" *load-path*)
(load-library "d-mode")
(pushnew '("\\.d$" . d-mode) *auto-mode-alist* :test 'equal)
```

#Problems
�EPredicted some unnecessary codes.

#License
MIT License