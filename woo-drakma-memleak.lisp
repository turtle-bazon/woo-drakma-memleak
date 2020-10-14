(ql:quickload :woo-drakma-memleak)

;;(woo-drakma-memleak:main-entry)
(sb-ext:save-lisp-and-die "woo-drakma-memleak" :toplevel #'woo-drakma-memleak:main-entry :executable t)

