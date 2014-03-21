;; -*- mode: Emacs-Lisp; auto-recompile: t -*-
;; ffap for Java (Thanks to ~wyrick)

(require 'ffap)

(defvar ffap-java-get-roots '(ffap-java-find-root)
  "A list of functions to call to get directories to search for a java file.
Each function should return a list of directory paths.")

(defun ffap-java-find-root ()
  (let* ((pkg (ffap-java-get-package-name))
         (dir (if (null pkg)
                  nil
                (ffap-java-class-to-fname pkg))))
    (if (and dir
             (string-match (concat "^\\(.*?\\)/" dir) buffer-file-name))
        (list (match-string-no-properties 1 buffer-file-name))
      nil)))

(defun ffap-java-class-to-fname (class)
  (subst-char-in-string ?. ?/ class))

(defun ffap-java-get-package-name ()
  (save-excursion
    (goto-char (point-min))
    (if (re-search-forward "^package\\s +\\([^;]+\\);" nil t)
        (match-string-no-properties 1)
      nil)))

(defun ffap-java-find-import-for (name)
  (save-excursion
    (goto-char (point-min))
    (let ((regex (concat "^import\\s +\\(?:static\\s +\\)?\\([^;]+\\." name "\\);"))
          (pkg (ffap-java-get-package-name)))
      (if (re-search-forward regex nil t)
          (match-string-no-properties 1)
        (goto-char (point-min))
        (if pkg
            (concat pkg "." name)
          nil)))))

(defun ffap-java-find-import-wildcards-for (name)
  (save-excursion
    (goto-char (point-min))
    (let ((regex (concat "^import\\s +\\(?:static\\s +\\)?\\([^;]+\\.\\)\\*;"))
          (ret (list)))
      (while (re-search-forward regex nil t)
        (add-to-list 'ret (concat (match-string-no-properties 1) name) t))
      ret)))

(defun ffap-java-mode (name)
  ;; ffap picks up List<MyType instead of just MyType on java generics
  ;; This hack fixes that
  (if (string-match "[^a-zA-Z0-9_.]" name)
      (setq name (current-word)))
  (let ((case-fold-search nil)
        (search-list (nconc (list name (ffap-java-find-import-for (current-word)))
                            (ffap-java-find-import-wildcards-for (current-word))))
        (dirs (apply #'nconc (mapcar 'funcall ffap-java-get-roots)))
        found)
    ;;(message (prin1-to-string search-list))
    ;;(message (prin1-to-string dirs))
    (while search-list
      (let ((try (car search-list)) parent)
        (unless (null try)
          (setq try (ffap-java-class-to-fname try))
          ;; look for file matching this class and 'enclosing' class for nested classes
          (setq parent (file-name-directory try))
          ;;(message (prin1-to-string try))
          (setq found
                (or (ffap-locate-file try
                                      '(".java") dirs nil)
                    (and parent
                         (ffap-locate-file (directory-file-name parent)
                                           '(".java") dirs nil))))))
      (if found
          (setq search-list nil)
        (setq search-list (cdr search-list))))
    found))

(add-to-list 'ffap-alist '(java-mode . ffap-java-mode))
(add-to-list 'ffap-alist '(jde-mode . ffap-java-mode))

(provide 'rew-ffap-java)
