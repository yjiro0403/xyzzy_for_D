;;; -*- Mode: Lisp; Package: EDITOR -*-
;;;
;;; This file is part of xyzzy.
;;;

(provide "d-mode")

(in-package "editor")

(export '(d-mode *default-d-mode* *d-comment-column*
	  *d-mode-hook* *d-keyword-file* *d-indent-tabs-mode*
	  d-indent-level d-continued-statement-offset
	  d-argdecl-indent d-brace-offset d-brace-imaginary-offset
	  d-label-offset d-preprocessor-offset d-comment-indent
	  detect-d-mode))

(defvar *dmode-hook* nil
  "d-mode: フック変数")

(unless (boundp 'd-indent-level)
  (setq d-indent-level 2)
  (setq d-continued-statement-offset 2)
  (setq d-argdecl-indent 5)
  (setq d-brace-offset 0)
  (setq d-brace-imaginary-offset 0)
  (setq d-label-offset -2)
  (setq d-preprocessor-offset nil)
  (setq d-comment-indent 2))

(defvar *d-keyword-hash-table* nil)
(defvar *d-keyword-file* "D")

(defvar *d-indent-tabs-mode* nil)
(defvar *d-comment-column* nil)

(defvar *d-mode-syntax-table* nil)
(unless *d-mode-syntax-table*
  (setq *d-mode-syntax-table* (make-syntax-table))
  (do ((x #x21 (1+ x)))((>= x #x7f))
    (let ((d (code-char x)))
      (unless (alphanumericp d)
	(set-syntax-punctuation *d-mode-syntax-table* d))))
  (set-syntax-option *d-mode-syntax-table*
		     (+ *syntax-option-c-preprocessor*
			*syntax-option-indent-c++*
			*syntax-option-indent-c++/cli*))
  (set-syntax-string *d-mode-syntax-table* #\")
  (set-syntax-string *d-mode-syntax-table* #\')
  (set-syntax-escape *d-mode-syntax-table* #\\)
  (set-syntax-symbol *d-mode-syntax-table* #\_)
  (set-syntax-symbol *d-mode-syntax-table* #\#)
  (set-syntax-match *d-mode-syntax-table* #\( #\))
  (set-syntax-match *d-mode-syntax-table* #\{ #\})
  (set-syntax-match *d-mode-syntax-table* #\[ #\])
  (set-syntax-start-multi-comment *d-mode-syntax-table* "/*")
  (set-syntax-end-multi-comment *d-mode-syntax-table* "*/")
  (set-syntax-start-c++-comment *d-mode-syntax-table* #\/)
  (set-syntax-end-c++-comment *d-mode-syntax-table* #\LFD))

(defvar *d-mode-map* nil)
(unless *d-mode-map*
  (setq *d-mode-map* (make-sparse-keymap))
  (define-key *d-mode-map* #\{ 'c-electric-insert)
  (define-key *d-mode-map* #\: 'c-electric-insert)
  (define-key *d-mode-map* #\# 'c-electric-insert)
  (define-key *d-mode-map* #\} 'c-electric-close)
  (define-key *d-mode-map* #\C-h 'backward-delete-char-untabify-or-selection)
  (define-key *d-mode-map* #\TAB 'c-indent-line)
  (define-key *d-mode-map* #\C-M-q 'indent-sexp)
  (define-key *d-mode-map* #\RET 'c-newline-and-indent))

(defvar *d-mode-abbrev-table* nil)
(unless *d-mode-abbrev-table*
  (define-abbrev-table '*d-mode-abbrev-table*))

(autoload 'c-build-summary-of-functions "cfns" nil)

(defun d-mode ()
  "d-mode"
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "d-mode")
  (setq buffer-mode 'd-mode)
  (use-syntax-table *d-mode-syntax-table*)
  (use-keymap *d-mode-map*)
  (make-local-variable 'mode-specific-indent-command)
  (setq mode-specific-indent-command 'c-indent-line)
  (make-local-variable 'd-comment-indent-variable)
  (setq d-comment-indent-variable 'd-comment-indent)
  (make-local-variable 'paragraph-start)
  (setq paragraph-start "^$\\|\f")
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'indent-tabs-mode)
  (setq indent-tabs-mode *d-indent-tabs-mode*)
  (make-local-variable 'tags-find-target)
  (setq tags-find-target #'c-tags-find-target)
  (make-local-variable 'tags-find-point)
  (setq tags-find-point #'c-tags-find-point)
  (make-local-variable 'build-summary-function)
  (setq build-summary-function 'c-build-summary-of-functions)
  (and *d-keyword-file*
       (null *d-keyword-hash-table*)
       (setq *d-keyword-hash-table*
	     (load-keyword-file *d-keyword-file*)))
  (when *d-keyword-hash-table*
    (make-local-variable 'keyword-hash-table)
    (setq keyword-hash-table *d-keyword-hash-table*))
  (setq *local-abbrev-table* *d-mode-abbrev-table*)
  (setq comment-start "// ")
  (setq comment-end "")
  (setq comment-start-skip "/\\(\\*+\\|/\\)[ \t]*")
  (setq comment-indent-function 'c-comment-indent)
  (when *d-comment-column*
    (setq comment-column *d-comment-column*))
  (run-hooks '*d-mode-hook*))

(defvar *default-d-mode* 'd-mode)

(defun detect-d-mode ()
  (interactive)
  (let ((mode (save-excursion
		(goto-char (point-min))
		(cond ((or (scan-buffer "//" :limit 3000)
			   (scan-buffer "\\(^\\|[^A-Za-z0-9_]\\)class\\($\\|[^A-Za-z0-9_]\\)"
					:regexp t :limit 3000)
			   (scan-buffer "\\(^\\|[^A-Za-z0-9_]\\)\\(public\\|private\\|protected\\)[ \t\n\f]*:"
					:regexp t :limit 3000))
		       'd-mode)
		      ((bufferp *auto-mode-last-buffer*)
		       (set-buffer *auto-mode-last-buffer*)
		       (and (boundp 'buffer-mode)
			    (or (eq buffer-mode 'd-mode)
				(eq buffer-mode 'd-mode))
			    buffer-mode))))))
    (funcall (or mode *default-d-mode*))))

(export 'decode-d-mode)
(setf (symbol-function 'decode-d-mode) #'detect-d-mode)
