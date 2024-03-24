(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
	"straight/repos/straight.el/bootstrap.el"
	(or (bound-and-true-p straight-base-dir)
	    user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
	(url-retrieve-synchronously
	 "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
	 'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq package-enable-at-startup nil)

(use-package evil
  :straight t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode))

(use-package evil-collection
  :straight t
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "RET") nil))
(setq org-return-follows-link t)

(use-package general
  :straight t
  :config
  (general-evil-setup)

  ;; setup SPC as global key
  (general-create-definer cr4zi/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (cr4zi/leader-keys
    "SPC" '(counsel-M-x :wk "Counsel M-x")
    "." '(find-file :wk "Find file")
    "fc" '((lambda () (interactive) (find-file "~/.emacs.d/config.org")) :wk "Open emacs config")
    "fr" '(counsel-recentf :wk "Find recent files")
    "TAB TAB" '(comment-line :wk "Comment lines"))

  (cr4zi/leader-keys
    "b" '(:ignore t :wk "buffer")
    "bb" '(switch-to-buffer :wk "Switch buffer")
    "bi" '(ibuffer :wk "Ibuffer")
    "bk" '(kill-this-buffer :wk "Kill this buffer")
    "bn" '(next-buffer :wk "Next buffer")
    "bp" '(previous-buffer :wk "Previous buffer")
    "br" '(revert-buffer :wk "Reload buffer"))

  (cr4zi/leader-keys
    "d" '(:ignore t :wk "Dired")
    "dd" '(dired :wk "Open dired")
    "dj" '(dired-jump :wk "Dired jump to current")
    "dn" '(dired-create-empty-file :wk "Dired create empty file")
    "dp" '(peed-dired :wk "Peep dired"))

  (cr4zi/leader-keys
    "e" '(:ignore t :wk "Evaluate")
    "eb" '(eval-buffer :wk "Evaluate elisp in buffer")
    "ed" '(eval-defun :wk "Evaluate defun containing or after point")
    "ee" '(eval-expression :wk "Evaluate and elisp expression")
    "el" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "er" '(eval-region :wk "Evaluate elisp in region"))

  (cr4zi/leader-keys
    "h" '(:ignore t :wk "Help")
    "hf" '(describe-function :wk "Describe function")
    "hv" '(describe-variable :wk "Describe variable")
    "hrr" '((lambda () (interactive) (load-file "~/.emacs.d/init.el")) :wk "Reload emacs config"))
  
  (cr4zi/leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "w c" '(evil-window-delete :wk "Close window")
    "w n" '(evil-window-new :wk "New window")
    "w s" '(evil-window-split :wk "Horizontal split window")
    "w v" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "w h" '(evil-window-left :wk "Window left")
    "w j" '(evil-window-down :wk "Window down")
    "w k" '(evil-window-up :wk "Window up")
    "w l" '(evil-window-right :wk "Window right")
    "w w" '(evil-window-next :wk "Goto next window")
    ;; Move Windows
    "w H" '(buf-move-left :wk "Buffer move left")
    "w J" '(buf-move-down :wk "Buffer move down")
    "w K" '(buf-move-up :wk "Buffer move up")
    "w L" '(buf-move-right :wk "Buffer move right"))

  (cr4zi/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "tl" '(display-line-numbers-mode :wk "Toggle line numbers")
    "td" '(treemacs :wk "Toggle treemacs")
    "tt" '(visual-line-mode :wk "Toggle truncated lines")
    "tv" '(vterm-toggle :wk "Toggle vterm"))

)

(use-package all-the-icons
  :straight t
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :straight t
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package beacon
  :straight t)

(beacon-mode 1)

(require 'windmove)

(defconst buffer-move-version "0.6.3"
  "Version of buffer-move.el")

(defgroup buffer-move nil
  "Swap buffers without typing C-x b on each window"
  :group 'tools)

(defcustom buffer-move-behavior 'swap
  "If set to 'swap (default), the buffers will be exchanged
  (i.e. swapped), if set to 'move, the current window is switch back to the
  previously displayed buffer (i.e. the buffer is moved)."
  :group 'buffer-move
  :type 'symbol)

(defcustom buffer-move-stay-after-swap nil
  "If set to non-nil, point will stay in the current window
  so it will not be moved when swapping buffers. This setting
  only has effect if `buffer-move-behavior' is set to 'swap."
  :group 'buffer-move
  :type 'boolean)

(defun buf-move-to (direction)
  "Helper function to move the current buffer to the window in the given
   direction (with must be 'up, 'down', 'left or 'right). An error is
   thrown, if no window exists in this direction."
  (cl-flet ((window-settings (window)
              (list (window-buffer window)
                    (window-start window)
                    (window-hscroll window)
                    (window-point window)))
            (set-window-settings (window settings)
              (cl-destructuring-bind (buffer start hscroll point)
                  settings
                (set-window-buffer window buffer)
                (set-window-start window start)
                (set-window-hscroll window hscroll)
                (set-window-point window point))))
    (let* ((this-window (selected-window))
           (this-window-settings (window-settings this-window))
           (other-window (windmove-find-other-window direction))
           (other-window-settings (window-settings other-window)))
      (cond ((null other-window)
             (error "No window in this direction"))
            ((window-dedicated-p other-window)
             (error "The window in this direction is dedicated"))
            ((window-minibuffer-p other-window)
             (error "The window in this direction is the Minibuffer")))
      (set-window-settings other-window this-window-settings)
      (if (eq buffer-move-behavior 'move)
          (switch-to-prev-buffer this-window)
        (set-window-settings this-window other-window-settings))
      (select-window other-window))))

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
   If there is no split, ie now window above the current one, an
   error is signaled."
  (interactive)
  (buf-move-to 'up))

;;;###autoload
(defun buf-move-down ()
  "Swap the current buffer and the buffer under the split.
   If there is no split, ie now window under the current one, an
   error is signaled."
  (interactive)
  (buf-move-to 'down))

;;;###autoload
(defun buf-move-left ()
  "Swap the current buffer and the buffer on the left of the split.
   If there is no split, ie now window on the left of the current
   one, an error is signaled."
  (interactive)
  (buf-move-to 'left))

;;;###autoload
(defun buf-move-right ()
  "Swap the current buffer and the buffer on the right of the split.
   If there is no split, ie now window on the right of the current
   one, an error is signaled."
  (interactive)
  (buf-move-to 'right))

;;;###autoload
(defun buf-move ()
  "Begin moving the current buffer to different windows.

Use the arrow keys to move in the desired direction.  Pressing
any other key exits this function."
  (interactive)
  (let ((map (make-sparse-keymap)))
    (dolist (x '(("<up>" . buf-move-up)
                 ("<left>" . buf-move-left)
                 ("<down>" . buf-move-down)
                 ("<right>" . buf-move-right)))
      (define-key map (read-kbd-macro (car x)) (cdr x)))
    (set-transient-map map t)))

(use-package company
  :ensure t
  :defer 2
  :diminish
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay 0.0)
  (company-minimum-prefix-length 1)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :straight t
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(use-package dired-open
  :straight t
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(use-package peep-dired
  :straight t
  :after dired
  :hook (evil-normalize-keymaps . peep-dired-hook)
  :config
    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
)

(use-package elcord
  :straight t)

(elcord-mode)
(setq elcord-editor-icon "emacs_material_icon")

(use-package dashboard
  :straight t
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  (setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-center-content nil) ;; set to 't' for centered content
  (setq dashboard-items '((recents . 5)
                          (agenda . 5 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  :custom
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(use-package diminish
  :straight t)

(use-package flycheck
  :straight t
  :ensure t
  :defer t
  :diminish
  :init (global-flycheck-mode))

(set-face-attribute 'default nil
  :font "FiraCode Nerd Font"
  :height 100
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "FiraCode Nerd Font"
  :height 100
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "FiraCode Nerd Font"
  :height 100
  :weight 'medium)
;; Makes commented text and keywords italics.
;; This is working in emacsclient but not emacs.
;; Your font must have an italic face available.
(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
;; Does the same thing as 'set-face-attribute default' above, but emacsclient fonts
;; are not right unless I also add this method of setting the default font.
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-10"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package nerd-icons
  :straight t)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode 1)
(setq display-line-numbers-type 'relative)

(setq scroll-step 1
      scroll-conservatively 10000)

(use-package counsel
  :straight t
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :straight t
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :straight t
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :straight t
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package python-mode
  :straight t)

(use-package lua-mode
  :straight t)

(use-package lsp-mode
  :straight t
  :init
  :hook(
    (python-mode . lsp-deferred)
    (c-mode . lsp-deferred)
    (lua-mode . lsp-deferred)
    (lsp-mode . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred))

(add-to-list 'load-path (expand-file-name "lib/lsp-mode" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "lib/lsp-mode/clients" user-emacs-directory))


(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode)


(use-package lsp-ivy
  :straight t
  :commands lsp-ivy-workspace-symbol)

(use-package lsp-treemacs
  :straight t
  :commands lsp-treemacs-errors-list
  :init
  (lsp-treemacs-sync-mode 1))

(setq lsp-modeline-diagnostics-enable t)
(setq lsp-lenses-enable t)
(setq lsp-headerline-breadcrumb-enable t)
(setq lsp-modeline-code-actions-enable t)
(setq lsp-completion-show-detail t)
(setq lsp-completion-show-kind t)
(setq lsp-ui-sideline-enable t)

(use-package magit
  :straight t
  :ensure t)

(add-hook 'org-mode-hook 'org-indent-mode)
  (use-package org-bullets
    :straight t)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(setq org-bullets-bullet-list '("✙" "♱" "♰" "☥" "✞" "✟" "✝" "†" "✠" "✚" "✜" "✛" "✢" "✣" "✤" "✥"))

(use-package toc-org
  :straight t
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(electric-indent-mode -1)
(setq org-edit-src-content-indentation 0)

(require 'org-tempo)

(use-package projectile
  :straight t
  :config
  (projectile-mode 1))

(use-package rainbow-mode
  :straight t
  :hook org-mode prog-mode)

(use-package vterm
  :straight t
  :config
  (setq shell-file--name "/bin/bash"))

(use-package vterm-toggle
  :straight t
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.3))))

(use-package sudo-edit
  :straight t
  :config
  (cr4zi/leader-keys
    "fu" '(sudo-edit-find-file :wk "Sudo find file")
    "fU" '(sudo-edit :wk "Sudo edit file")))

(use-package treemacs
  :straight t)

(use-package treemacs-evil
  :straight t
  :after treemacs)

(use-package doom-themes
  :straight t
  :ensure t
  :config
    ;; Global settings (defaults)
    (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
          doom-themes-enable-italic t) ; if nil, italics is universally disabled
    ;; (load-theme 'doom-one t)

    ;; Enable flashing mode-line on errors
    (doom-themes-visual-bell-config)
    ;; Enable custom neotree theme (all-the-icons must be installed!)
    (doom-themes-neotree-config)
    ;; or for treemacs users
    ;; (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
    ;; (doom-themes-treemacs-config)
    ;; Corrects (and improves) org-mode's native fontification.
    (doom-themes-org-config))

(use-package kaolin-themes
  :straight t
  :ensure t
  :config
  (kaolin-treemacs-theme)
)

(load-theme 'kaolin-dark t)

(set-frame-parameter nil 'alpha-background 90)

(add-to-list 'default-frame-alist '(alpha-background . 90))

(use-package doom-modeline
  :straight t
  :config
    (setq doom-modeline-height 30)
  :init (doom-modeline-mode 1))

(use-package which-key
  :straight t
  :init
  (which-key-mode 1)
  :config
  (setq which-key-side-window-location 'bottom
	which-key-sort-order #'which-key-key-order-alpha
	which-key-allow-imprecise-window-fit nil
	which-key-sort-uppercase-first nil
	which-key-add-column-padding 1
	which-key-max-display-columns nil
	which-key-min-display-lines 6
	which-key-side-window-slot -10
	which-key-side-window-max-height 0.25
	which-key-idle-delay 0.8
	which-key-max-description-length 25
	which-key-allow-imprecise-window-fit nil
	which-key-separator " → " ))
