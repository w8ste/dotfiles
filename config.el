(defvar elpaca-installer-version 0.5)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
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
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))
;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
    (setq elpaca-use-package-by-default t))

  ;; Block until current queue processed.
  (elpaca-wait)

  ;;When installing a package which modifies a form used at the top-level
  ;;(e.g. a package which adds a use-package key word),
  ;;use `elpaca-wait' to block until that package has been installed/configured.
  ;;For example:
  ;;(USE-package general :demand t)
  ;;(elpaca-wait)
  ;;Turns off elpaca-use-package-mode current declartion
  ;;Note this will cause the declaration to be interpreted immediately (not deferred).
  ;;Useful for configuring built-in emacs features.
  (use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

  ;; Don't install anything. Defer execution of BODY
  ;;(elpaca nil (message "deferred"))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-vsplit-window-right t)
  (setq evil-split-window-below t)
  (evil-mode))
(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-mode-list '(dashboard dired ibuffer))
  (evil-collection-init))

;; settings keybindings for evil
(with-eval-after-load 'evil-maps
(define-key evil-motion-state-map (kbd "SPC") nil)
(define-key evil-motion-state-map (kbd "RET") nil)
(define-key evil-visual-state-map (kbd "C-c") 'evil-normal-state)
(define-key evil-insert-state-map (kbd "C-c") 'evil-normal-state)
(define-key evil-motion-state-map (kbd "C-e") nil)
(define-key evil-visual-state-map (kbd "C-c") 'evil-exit-visual-state)
(define-key evil-motion-state-map (kbd "TAB") nil))

(use-package general
       :config
       (general-evil-setup)
        ;; set up 'SPC' as the global leader key
     (general-create-definer w8ste/leader-keys
       :states '(normal insert visual emacs)
       :keymaps 'override
       :prefix "SPC" ;; set leader
       :global-prefix "M-SPC") ;; access leader in insert mode

     ;; buffer keybindings
     (w8ste/leader-keys
       "b" '(:ignore t :wk "buffer")
       "bb" '(switch-to-buffer :wk "Switch buffer")
       "bk" '(kill-this-buffer :wk "Kill this buffer")
       "bi" '(ibuffer :wk "Ibuffer")
       "bn" '(next-buffer :wk "Next buffer")
       "bp" '(previous-buffer :wk "Previous buffer")
       "br" '(revert-buffer :wk "Reload buffer"))

 ;; quality of life keybindings
 (w8ste/leader-keys
  "f c" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
  "TAB TAB" '(comment-line :wk "Comment lines"))

  ;; eval keybindings
  (w8ste/leader-keys
    "e" '(:ignore t :wk "Evaluate")    
    "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
    "e d" '(eval-defun :wk "Evaluate defun containing or after point")
    "e e" '(eval-expression :wk "Evaluate and elisp expression")
    "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
    "e r" '(eval-region :wk "Evaluate elisp in region"))

 (w8ste/leader-keys
   "h" '(:ignore t :wk "Help")
   "h f" '(describe-function :wk "Describe function")
   "h v" '(describe-variable :wk "Describe variable"))

 (w8ste/leader-keys
  "t" '(:ignore t :wk "Toggle")
  "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
  "t t" '(visual-line-mode :wk "Toggle truncated lines"))
 )
 ;; Setting RETURN key in org-mode to follow links
   (setq org-return-follows-link  t)

(set-face-attribute 'default nil
  :font "JetBrains Mono"
  :height 110
  :weight 'medium)
(set-face-attribute 'variable-pitch nil
  :font "Monospace"
  :height 120
  :weight 'medium)
(set-face-attribute 'fixed-pitch nil
  :font "JetBrains Mono"
  :height 110
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
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))

;; Uncomment the following line if line spacing needs adjusting.
(setq-default line-spacing 0.12)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(global-visual-line-mode t)

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(use-package which-key
:init
  (which-key-mode 1)
:config
(setq which-key-side-window-location 'bottom
	which-key-sort-order #'which-key-key-order-alpha
	which-key-sort-uppercase-first nil
	which-key-add-column-padding 1
	which-key-max-display-columns nil
	which-key-min-display-lines 6
	which-key-side-window-slot -10
	which-key-side-window-max-height 0.25
	which-key-idle-delay 0.8
	which-key-max-description-length 25
	which-key-allow-imprecise-window-fit t
	which-key-separator " → " ))

(use-package elcord
  :init
  (elcord-mode))
