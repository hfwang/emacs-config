;; Note to self: Want to bind something? Use global-set-key, then try "C-x ESC ESC C-a C-k C-g"

(defun make-load-path-base ()
  "Constructs a load path base by looking at where the .emacs file lives."
  (concat (file-name-directory (file-chase-links "~/.emacs")) "site-lisp/"))

(defun add-to-load-path (&rest args)
  "Adds the directories given to the load path under the site-lisp directory."
  (let ((site-lisp-base (make-load-path-base)))
    (mapc '(lambda (arg)
               (add-to-list 'load-path
                            (concat site-lisp-base arg))) args)))

;; (setq load-path nil)
(add-to-load-path
 "anything"
 "el"
 "ruby-mode"
 "rinari"
 "tramp-2.1.15")

;; OMG COLORS NAO
(add-to-list 'custom-theme-load-path
             (concat (file-name-directory (file-chase-links "~/.emacs"))
                     "site-lisp/themes/"))
(load-theme 'zenburn t)

;; faster startup
(modify-frame-parameters nil '((wait-for-wm . nil)))

;; interactive do
(ido-mode t)
(setq ido-enable-flex-matching t)

;; undo and redo changes in window configuration with C-c <left/right>
(winner-mode 1)

;; Display column number
(column-number-mode 1)

;; No more starting splash
(setq inhibit-startup-message t)

;; Syntax highlight!
(global-font-lock-mode 1)

;; always end a file with a newline
(setq require-final-newline t)

;; stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)

;; don't pop up windows.
(setq pop-up-windows nil)
(setq pop-up-frames nil)

(when window-system
  ;; use extended compound-text coding for X clipboard
  (set-selection-coding-system 'compound-text-with-extensions))

;; OMG MORE SCREEN SPACE!
(menu-bar-mode 0)
(if window-system
    (tool-bar-mode 0))

;; Enable wheelmouse support by default
(require 'mwheel)
(mwheel-install)

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

;; End key that works via putty woo!
(global-set-key [select] 'end-of-line)
;; ...and on Mac with USB keyboard
(global-set-key [end] 'end-of-line)

;; Control arrow keys
(define-key function-key-map "\eO1;5A" [C-up]) ;; Control arrows in terminal
(define-key function-key-map "\eO1;5B" [C-down])
(define-key function-key-map "\eO1;5C" [C-right])
(define-key function-key-map "\eO1;5D" [C-left])
(global-set-key "\M-[C" 'forward-word) ;; Control arrow keys in putty
(global-set-key "\M-[D" 'backward-word)
(global-set-key "\M-[A" 'backward-paragraph)
(global-set-key "\M-[B" 'forward-paragraph)
(global-set-key (quote [27 up]) 'backward-paragraph)
(global-set-key (quote [27 down]) 'forward-paragraph)

;; alt-f4 to quit
(defun really-delete-frame () (delete-frame 1))
(global-set-key [\M-f4] 'really-delete-frame)

;; windmove
(global-set-key (read-kbd-macro "C-x <up>") 'windmove-up) ; for emacs in X
(global-set-key (read-kbd-macro "C-x <down>") 'windmove-down)
(global-set-key (read-kbd-macro "C-x <left>") 'windmove-left)
(global-set-key (read-kbd-macro "C-x <right>") 'windmove-right)
(global-set-key (kbd "C-x <up>") 'windmove-up) ; for putty
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)

;; Reload file on [f5]
(global-set-key [f5] 'revert-buffer)

;; Make selection visible in terminal
(setq transient-mark-mode t)

;; disable backup
(setq backup-inhibited t)
;; disable auto save
(setq auto-save-default nil)

;; We are quite opinionated regarding whitespace
(setq show-trailing-whitespace nil)
(setq-default indent-tabs-mode nil)

(defun delete-trailing-space ()
  "Deletes trailing space from all lines in buffer."
  (interactive)
  (or buffer-read-only
                (save-excursion
                  (message "Deleting trailing spaces ... ")
                  (goto-char (point-min))
                  (while (< (point) (point-max))
                         (end-of-line nil)
                         (delete-horizontal-space)
                         (forward-line 1))
                  (message "Deleting trailing spaces ... done.")))
  nil
  ) ; indicates buffer-not-saved for write-file-hook
;; remove trailing spaces before saving the buffer
(or (memq 'delete-trailing-whitespace write-file-hooks)
         (setq write-file-hooks (cons 'delete-trailing-whitespace write-file-hooks)))

(setq-default fill-column 80)

(global-set-key [f2] 'ffap)

;; Try out this "Anything" that people are always talking about...
(require 'anything)
(global-set-key "\M-`" 'anything)

;; Use full-ack for ack
(autoload 'ack-same "full-ack" nil t)
(autoload 'ack "full-ack" nil t)
(autoload 'ack-find-same-file "full-ack" nil t)
(autoload 'ack-find-file "full-ack" nil t)

;; Use highlight-symbol.
(require 'highlight-symbol)
(global-set-key [(control f3)] 'highlight-symbol-at-point)
(global-set-key "[13~" 'highlight-symbol-at-point)
(global-set-key "\eO1;5R" 'highlight-symbol-at-point)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)
(global-set-key "\eO1;2R" 'highlight-symbol-prev)
(global-set-key [(meta f3)] 'highlight-symbol-prev)
(global-set-key "\eO1;3R" 'highlight-symbol-prev)

;; ...and use highlight-parentheses
(require 'highlight-parentheses)
(highlight-parentheses-mode)

;; Use xterm-extras for the keyboard mapping.
(when (string-match "^xterm" (or (getenv "TERM") "X11"))
  (require 'xterm-extras)
  (xterm-extra-keys))

;; Simple Lisp Files
(require 'hfwang) ;; import "my" elisp.
(global-set-key "\M-i" 'ido-goto-symbol)
(global-set-key [home] 'smart-beginning-of-line)
(global-set-key "\C-a" 'smart-beginning-of-line)
;; goto line via ctrl-x g and column via ctrl-x j
(define-key ctl-x-map "g" 'goto-line)
(define-key ctl-x-map "\C-g" 'goto-column)

(require 'pabbrev)
(global-pabbrev-mode)
(setq pabbrev-minimal-expansion-p t)

(require 'show-wspace)
(setq-default show-trailing-whitespace 1)
;; (show-ws-toggle-show-trailing-whitespace)
(show-ws-toggle-show-tabs)

(require 'php-mode)
(require 'psvn)
(require 'lineker)
(global-hl-line-mode)
(require 'quick-yes)

(put 'set-goal-column 'disabled nil)
(put 'narrow-to-region 'disabled nil)

(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;; Predictive mode
;; (add-to-list 'load-path "~/.emacs.d/predictive")
;; (autoload 'predictive-mode "predictive" "predictive" t)
;; (set-default 'predictive-auto-add-to-dict t)
;; (setq predictive-auto-learn t
;;       predictive-add-to-dict-ask nil
;;       predictive-use-auto-learn-cache nil)

(require 'browse-kill-ring)
(browse-kill-ring-default-keybindings)

;; ----------------------------------------------------------------------
;; Alias some commonly used functions.
;; ----------------------------------------------------------------------
(defalias 'rs 'replace-string)

;; ----------------------------------------------------------------------
;; File-specific major-mode type stuff.
;; ----------------------------------------------------------------------

;; CSS mode
(autoload 'css-mode "css-mode")
;; (add-to-list auto-mode-alist '("\\.css\\'" . css-mode))
;;try to fix strange stuff in css mode.
(setq cssm-indent-level 2)
(setq cssm-newline-before-closing-bracket t)
(setq cssm-indent-function #'cssm-c-style-indenter)

(autoload 'csharp-mode "csharp-mode" "Major mode for editing C# code." t)
(require 'csharp-mode)

;; Use espresso mode instead of js2 mode.
;; (autoload #'espresso-mode "espresso" "Start espresso-mode" t)
;; (add-to-list 'auto-mode-alist '("\\.js$" . espresso-mode))
;; (add-to-list 'auto-mode-alist '("\\.json$" . espresso-mode))

;; Use jshint for flymake
(require 'flymake-node-jshint)
(add-hook 'js-mode-hook (lambda () (flymake-mode 1)))

;; Moonscript mode!
(autoload 'moonscript-mode "moonscript-mode")
(add-to-list 'auto-mode-alist '("\\.moon\\'" . moonscript-mode))

;; Lua mode!
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;; Ruby on Emacs!
;; Ruby Mode
(autoload 'ruby-mode "ruby-mode")
(add-to-list 'auto-mode-alist '("\\.rb\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))

;; Rinari Mode (Rails)
(require 'rinari)

;; HAML+SASS!
(require 'haml-mode)
(require 'sass-mode)

;; Prettier buffer names.
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward)

;; Edit files...over the internet!
(require 'tramp)
(setq tramp-default-method "plink")
(setq tramp-default-method "sshx")

;; ;; CEDET
;; (add-to-list 'load-path "~/.emacs.d/cedet/common")
;; (require 'cedet)
;; (semantic-load-enable-code-helpers)

;; ;; Elib (for JDEE)
;; (add-to-list 'load-path "~/.emacs.d/elib")

;; ;; JDEE, Aww yeah
;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/jde/lisp"))
;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/cedet/common"))
;; (load-file (expand-file-name "~/.emacs.d/cedet/common/cedet.el"))
;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/elib"))
;; (require 'jde)

;; Conditionally load other stuff (host specific)
(let ((host-specific-files (concat (make-load-path-base) system-name ".el")))
  (if (file-exists-p host-specific-files)
      (load host-specific-files)
    (message (concat "No host specific customizations for " system-name))
  ))

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:weight normal :height 100 :width normal))))
 '(col-highlight ((((class color)) (:background "black"))))
 '(column-marker-1 ((((class color)) (:background "black"))))
 '(column-marker-2 ((((class color)) (:background "black"))))
 '(column-marker-3 ((((class color)) (:background "black"))))
 '(flymake-errline ((((class color)) (:background "red4"))))
 '(flymake-warnline ((((class color)) (:background "red4"))))
 '(hl-line ((((class color)) (:background "black"))))
 '(mumamo-background-chunk-submode ((((class color) (min-colors 88) (background light)) nil))))
;; I don't like the default colors :)
(set-face-background 'flymake-errline "red4")
(set-face-background 'flymake-warnline "dark slate blue")

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(dta-default-cfg "default.conf")
 '(espresso-comment-lineup-func (quote c-lineup-C-comments))
 '(espresso-expr-indent-offset 4)
 '(espresso-indent-level 2)
 '(espresso-js-timeout 5)
 '(espresso-js-tmpdir "~/.emacs.d/espresso/js")
 '(javascript-indent-level 2)
 '(safe-local-variable-values (quote ((auto-recompile . t)))))

(require 'flymake-ruby)
(add-hook 'ruby-mode-hook 'flymake-ruby-load)

(require 'column-marker)
(add-hook 'find-file-hook (lambda () (interactive) (column-marker-1 80)))
(add-hook 'find-file-hook (lambda () (interactive) (column-marker-2 100)))
;;  (require 'crosshairs)
;; (toggle-crosshairs-when-idle)

(require 'autopair)
(autopair-global-mode 1)

;; At end because we want everything to have loaded.
(require 'smex)
(smex-initialize)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-c M-x") 'smex-update-and-run)
;; This is your old M-x.
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)
