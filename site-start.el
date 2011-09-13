(add-to-list 'auto-mode-alist (cons "\\.ml[iylpt]?$" 'caml-mode))

(autoload 'caml-mode "caml" "Major mode for editing Caml code." t)
(autoload 'run-caml "inf-caml" "Run an inferior Caml process." t)
(autoload 'camldebug "camldebug" (interactive) "Debug caml mode")

(if window-system (require 'caml-font))