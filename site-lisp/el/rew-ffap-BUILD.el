;; -*- mode: Emacs-Lisp; auto-recompile: t -*-
;; ffap for BUILD files. (Thanks to ~wyrick)

(require 'ffap)

(defvar ffap-BUILD-get-roots '(ffap-BUILD-google-find-roots)
  "A list of functions to call to get directories to search for a BUILD file.
Each function should return a list of directory paths.")

(defun ffap-BUILD-google-find-roots ()
  (let ((dirs (list "/google/src/head/depot/google3"
                    "/home/build/google3")))
    (when (string-match "^\\(.*\\)\\(/READONLY\\)?/google3/" buffer-file-name)
      (let ((root (file-name-as-directory (match-string 1 buffer-file-name))))
        (setq dirs (nconc (list (concat root "google3")
                                (concat root "READONLY/google3"))
                           dirs))))
    dirs))

(defun ffap-BUILD-mode (name)
  (let ((dirs (apply #'nconc (mapcar 'funcall ffap-BUILD-get-roots))))
    (if (string-match "^//\\([^:]*\\)" name)
        (setq name (match-string 1 name)))
    (if (not (string-match "/\\$" name))
        (setq name (concat name "/")))
    (setq name (concat name "BUILD"))
    (ffap-locate-file name nil dirs nil)))

(add-to-list 'ffap-alist '(google3-build-mode . ffap-BUILD-mode))

(provide 'rew-ffap-BUILD)
