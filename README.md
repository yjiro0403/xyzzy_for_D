#README
Because this program is not complated, it is updated some time. If you will help me to update this code, get in touch freely.

#Install
1. move "d-mode.l" to "xyzzy/lisp" or other directory
2. move "D" to "xyzzy/etc" (you add code in this file, it will be colored on xyzzy)
3. load "d-mode.l" on directory you moved

```lisp:site-init.l
;Add D-mode
(push "D:/xyzzy/lisp/d-mode" *load-path*)
(load-library "d-mode")
(pushnew '("\\.d$" . d-mode) *auto-mode-alist* :test 'equal)
```

#Problems
Predicted some unnecessary codes.

#License
MIT License
