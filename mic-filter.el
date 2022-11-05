;;; mic-filter.el --- Filter definitions for mic  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  ROCKTAKEY

;; Author: ROCKTAKEY <rocktakey@gmail.com>

;;; Commentary:

;; Filter definitions for `mic'.

;;; Code:
(require 'mic)

(defsubst mic-make-sexp-hook-quote (alist)
  "Create `add-hook' sexp from ALIST.
`car' of each element is HOOK, and `cdr' is FUNCTION.
FUNCTION should not be quoted."
  (mapcar
   (lambda (arg)
     `(add-hook ',(car arg) #',(cdr arg)))
   alist))

(defun mic-filter-hook-quote (plist)
  "Append sexp from value of :hook to value of :eval on PLIST.
Sexp is generated by `mic-make-sexp-hook-quote'."
  (mic-plist-put-append plist :eval
                        (mic-make-sexp-hook-quote
                         (plist-get plist :hook)))
  (mic-plist-delete plist :hook)
  plist)



(defun mic-filter-straight (plist)
  "Create `straight-use-package' sexp from PLIST and append to value of :eval.
This filter use `:straight' keyword."
  (mic-plist-put-append
   plist :eval-installation
   (mapcar
    (lambda (arg)
      `(straight-use-package ',arg))
    (plist-get plist :straight)))
  (mic-plist-delete plist :straight))

(defun mic-filter-el-get (plist)
  "Create `el-get-bundle' sexp from PLIST and append to value of :eval.
This filter use `:el-get' keyword."
  (mic-plist-put-append
   plist :eval-installation
   (mapcar
    (lambda (arg)
      `(el-get-bundle ,@(if (listp arg) arg (list arg))))
    (plist-get plist :el-get)))
  (mic-plist-delete plist :el-get))

(provide 'mic-filter)
;;; mic-filter.el ends here
