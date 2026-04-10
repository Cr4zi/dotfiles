(setq gc-cons-threshold 100000000)

(add-to-list 'load-path "~/.config/emacs/lisp")
(require 'gcmh)
(gcmh-mode 1)

(setq package-enable-at-startup nil)

(setopt frame-inhibit-implied-resize t)
(setopt frame-resize-pixelwise t)
