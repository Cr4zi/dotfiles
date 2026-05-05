(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(electric-indent-mode -1)
(electric-pair-mode 1)

(setq inhibit-startup-screen t)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)
(setq display-line-numbers-type 'relative)

(setq scroll-step            1
      scroll-conservatively  10000)

(setq make-backup-files nil) ; stop creating ~ files

(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

(set-face-attribute 'default nil :font "Iosevka Simple" :height 150)
(add-to-list 'default-frame-alist '(alpha-background . 80))

(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable use-package :ensure support for Elpaca.
  (elpaca-use-package-mode))

(use-package evil
  :ensure t
  :defer t
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :custom
  (evil-collection-setup-minibuffer t)
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  :init
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package modus-themes
  :ensure t
  :config
  (load-theme 'modus-vivendi t))

(use-package ef-themes
  :ensure t
  :config
  (load-theme 'ef-bio t))


(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(use-package general
  :ensure t
  :demand t
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

  (leader-keys
    "." '(find-file :wk "Find file")
    "fp" '(lambda () (interactive)
	     (find-file "~/.config/emacs/init.el"))
    "TAB TAB" '(comment-line :wk "Comment lines"))

  (leader-keys
    "b" '(:ignore t :wk "buffer")
    "bb" '(consult-buffer :wk "Switch buffer")
    "bi" '(ibuffer :wk "Ibuffer")
    "bk" '(kill-current-buffer :wk "Kill this buffer")
    ;; I know those are reversed it's intentioanl
    "bn" '(previous-buffer :wk "Next buffer")
    "bp" '(next-buffer :wk "Previous buffer")
    "br" '(revert-buffer :wk "Reload buffer"))

  (leader-keys
    "e" '(:ignore t :wk "Evaluate")    
    "eb" '(eval-buffer :wk "Evaluate elisp in buffer")
    "ed" '(eval-defun :wk "Evaluate defun containing or after point")
    "ee" '(eval-expression :wk "Evaluate and elisp expression")
    "el" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "er" '(eval-region :wk "Evaluate elisp in region")) 

  (leader-keys
    "h" '(:ignore t :wk "Help")
    "hf" '(describe-function :wk "Describe function")
    "hv" '(describe-variable :wk "Describe variable")
    "hrr" '(reload-init-file :wk "Reload emacs config"))

  (leader-keys
    "w" '(:ignore t :wk "Windows")
    ;; Window splits
    "wc" '(evil-window-delete :wk "Close window")
    "wn" '(evil-window-new :wk "New window")
    "ws" '(evil-window-split :wk "Horizontal split window")
    "wv" '(evil-window-vsplit :wk "Vertical split window")
    ;; Window motions
    "wh" '(evil-window-left :wk "Window left")
    "wj" '(evil-window-down :wk "Window down")
    "wk" '(evil-window-up :wk "Window up")
    "wl" '(evil-window-right :wk "Window right")
    "ww" '(evil-window-next :wk "Goto next window"))

  (leader-keys
    "mp" '(man :wk "Open man menu")
    "mc" '(projectile-compile-project :wk "Projectile compile"))
  
  (leader-keys
    "g" '(:ignore t :wk "Git")    
    "g/" '(magit-displatch :wk "Magit dispatch")
    "g." '(magit-file-displatch :wk "Magit file dispatch")
    "gb" '(magit-branch-checkout :wk "Switch branch")
    "gc" '(:ignore t :wk "Create") 
    "gcb" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "gcc" '(magit-commit-create :wk "Create commit")
    "gcf" '(magit-commit-fixup :wk "Create fixup commit")
    "gC" '(magit-clone :wk "Clone repo")
    "gf" '(:ignore t :wk "Find") 
    "gfc" '(magit-show-commit :wk "Show commit")
    "gff" '(magit-find-file :wk "Magit find file")
    "gfg" '(magit-find-git-config-file :wk "Find gitconfig file")
    "gF" '(magit-fetch :wk "Git fetch")
    "gg" '(magit-status :wk "Magit status")
    "gi" '(magit-init :wk "Initialize git repo")
    "gl" '(magit-log-buffer-file :wk "Magit buffer log")
    "gr" '(vc-revert :wk "Git revert file")
    "gs" '(magit-stage-file :wk "Git stage file")
    "gt" '(git-timemachine :wk "Git time machine")
    "gu" '(magit-stage-file :wk "Git unstage file"))
  
   (leader-keys
     "pp" '(projectile-switch-project :wk "Projectile switch"))
  
   (leader-keys
     "cd" '(evil-goto-definition :wk "Go To Definition"))
  
   (leader-keys
    "ot" '(vterm-other-window :wk "Vterm"))
   
   (leader-keys
     "/" '(consult-line :wk "Consult Line"))
)

(use-package ivy
  :ensure t
  :init
  (ivy-mode))

(use-package emacs
  :custom
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :ensure t
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package company
  :ensure t
  :config
  (global-company-mode t))

(use-package company-box
  :after company
  :ensure t
  :diminish
  :hook (company-mode . company-box-mode))

(use-package projectile
  :ensure t
  :defer t
  :config
  (projectile-mode 1))

(use-package transient
  :ensure t
  :demand t)
(use-package magit
  :ensure t)

(use-package nasm-mode
  :config
  (add-to-list 'auto-mode-alist '("\\.\\(asm\\|s\\|inc\\)$" . nasm-mode))
  :ensure t)

(use-package typst-ts-mode
  :ensure (:type git :host codeberg :repo "meow_king/typst-ts-mode" :branch "main")
  :custom
  (typst-ts-watch-options "--open")
  (typst-ts-mode-grammar-location (expand-file-name "tree-sitter/libtree-sitter-typst.so" user-emacs-directory))
  (typst-ts-mode-enable-raw-blocks-highlight t)
  :config
  (keymap-set typst-ts-mode-map "C-c C-c" #'typst-ts-tmenu))

(require 'eglot)
;; C/C++
(add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)

;; Python
(add-to-list 'eglot-server-programs '(python-mode .("pyright-langserver" "--stdio")))
(add-hook 'python-mode-hook 'eglot-ensure)

;; Typst
(add-to-list 'eglot-server-programs '(typst-ts-mode . ("tinymist" "lsp")))
(add-hook 'typst-ts-mode-hook 'eglot-ensure)


(use-package which-key
  :ensure t
  :init
  (which-key-mode 1)
  :diminish
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

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(use-package vterm
  :ensure t)

(use-package consult
  :ensure t)
;; (use-package elcord
;;   :ensure t
;;   :demand t
;;   :init
;;   (elcord-mode t))
;;   :custom
;;   (setq elcord-editor-icon "emacs_material_icon")

(setq tramp-terminal-type "xterm")

;; (setq flymake-show-diagnostics-at-end-of-line t)

(setq gdb-many-windows t)
