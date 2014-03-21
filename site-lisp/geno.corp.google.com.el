;; Set this to -1 to read files from srcfs
(defvar google-localdisk-path-maximum-lag -1)
;; ...and load the initial google.el from srcfs. Ideally we would not use "head"
;; here but there is bootstrap problem.  The code to read the "head" cl is in
;; google-paths.el and gets used for loading all other .el files other than
;; google.el
(load-file "/google/src/head/depot/eng/elisp/google.el")

(require 'google-imports)
(global-unset-key (kbd "C-x i"))
(global-set-key (kbd "C-x i s") 'google-imports-organize-imports)
(global-set-key (kbd "C-x i g") 'google-imports-grab-import)
(global-set-key (kbd "C-x i i") 'google-imports-add-grabbed-imports)

(global-set-key [(meta f2)] 'gtags-feeling-lucky)
(global-set-key "OQ" 'gtags-feeling-lucky)
(global-set-key [(control f2)] 'gtags-show-tag-locations-under-point)
(global-set-key "O1;5Q" 'gtags-show-tag-locations-under-point)

(require 'google-java)
(require 'p4-google)
(g4-set-g4-executable "/usr/local/symlinks/g4")
(setq p4-use-p4config-exclusively t)

(add-to-list 'auto-mode-alist
             '("\\btmp.*\\.[pg]4-[a-z]*.txt$" . p4-spec-mode))
(autoload 'p4-spec-mode "p4-spec" t nil)

(fset 'html-mode 'nxhtml-mumamo-mode)            ; Google emacs was giving me crap with gxp without this...
(fset 'html-helper-mode 'nxhtml-mumamo-mode)     ; (and this)
(add-to-list 'auto-mode-alist '("\\.gxp\\'" . nxml-mumamo-mode))

;(ignore-errors (load-file "/home/stevey/emacs/lisp/jhtml-bootstrap.el"))
(require 'google-flymake)

(add-to-list 'load-path "/home/build/eng/elisp/third_party/gnuemacs")

(defun google3ify (dir)
  "Find the highest-level parent directory of dir that is named google3."
  (if (null dir) nil
    (let* ((dir (concat "/" dir "/"))
           (first-match (string-match "/google3/" dir)))
      (if first-match
          (substring dir 0 (match-end 0))))))

(defun client (dir)
  "Find the name of the current client (based on directory name)."
  (let ((default "n/a") ;; the emacs not in any client returns n/a
        (g3dir (google3ify dir)))
    (if (null g3dir) default
      (let* ((dirs (split-string g3dir "/" t))
             (ndirs (length dirs)))
        (if (< ndirs 2) default
          (elt dirs (- ndirs 2)))))))

(defun include-client-in-buffer-name ()
  (interactive)
  (let ((client-name (client default-directory)))
    (if (and client-name (buffer-file-name))
        (rename-buffer (format "%s [%s]" (file-name-nondirectory (buffer-file-name)) client-name) t))))


(add-hook 'find-file-hook 'include-client-in-buffer-name)
(add-hook 'dired-mode-hook 'include-client-in-buffer-name)

;; Generate Google GXP boilerplate code
(defun gengxp ()
 "Generate Google GXP boilerplate code"
 (interactive)
 (save-excursion
   (beginning-of-buffer)
   (insert (shell-command-to-string
             (concat "/home/hfwang/gengxp "
               (shell-quote-argument (buffer-file-name)))))))

(require 'rew-ffap-BUILD)

(require 'rew-ffap-java)
(defun ffap-java-google-find-roots ()
  (let (root dirs)
    (when (string-match "^\\(.*?\\)\\(/READONLY\\)?/google3/" buffer-file-name)
      (setq root (file-name-as-directory (match-string 1 buffer-file-name)))
      (setq dirs (list (concat root "google3/java")
                       (concat root "READONLY/google3/java")
                       (concat root "google3/javatests")
                       (concat root "READONLY/google3/javatests")
                       (concat root "google3/blaze-genfiles/java")
                       (concat root "google3/mgenfiles/java")
                       (concat root "google3/genfiles/java"))))
    dirs))

(add-hook 'ffap-java-get-roots 'ffap-java-google-find-roots t)

;; Google compile on [f12]
(global-set-key [f12] 'google-compile)
;; Google compile on [f11]
(global-set-key [f11] 'google-lint)
(require 'flymake-ler)

(add-to-list 'auto-mode-alist '("\\.jhtml\\'" . nxml-mumamo-mode))
