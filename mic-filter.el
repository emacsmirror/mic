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
                         (plist-get plist :hook-quote)))
  (mic-plist-delete plist :hook-quote)
  plist)



(defun mic-filter-el-get (plist)
  "Create `el-get-bundle' sexp from PLIST and append.
It is appended to value of `:eval-installation'.
This filter use `:el-get' keyword."
  (mic-plist-put-append
   plist :eval-installation
   (mapcar
    (lambda (arg)
      `(el-get-bundle ,@(if (listp arg) arg (list arg))))
    (plist-get plist :el-get)))
  (mic-plist-delete plist :el-get))

(defun mic-filter-straight (plist)
  "Create `straight-use-package' sexp from PLIST and append.
It is appended to value of `:eval-installation'.
This filter use `:straight' keyword."
  (mic-plist-put-append
   plist :eval-installation
   (mapcar
    (lambda (arg)
      `(straight-use-package ',arg))
    (plist-get plist :straight)))
  (mic-plist-delete plist :straight))



(defsubst mic-make-sexp-define-key-general (alist)
  "Create `general-define-key' sexp from ALIST.
`car' of each element is keymap, and `cdr' is list whose element is
\(KEY-STRING . COMMAND)."
  (mapcar
   (lambda (keymap-binds-alist)
     (let ((keymap (car keymap-binds-alist))
           (binds (cdr keymap-binds-alist)))
       `(general-define-key
         :keymaps ',keymap
         ,@(mapcan
            (lambda (bind)
              (let ((key (car bind))
                    (command (cdr bind)))
                `(,key ,command)))
            binds))))
   alist))

(defun mic-filter-define-key-general (plist)
  "Append sexp from value of :general-define-key to value of :eval on PLIST.
Sexp is generated by `mic-make-sexp-define-key-general'."
  (mic-plist-put-append plist :eval
                        (mic-make-sexp-define-key-general
                         (plist-get plist :define-key-general)))
  (mic-plist-delete plist :define-key-general)
  plist)

(defsubst mic-make-sexp-general-define-key (list)
  "Create `general-define-key' sexp from LIST.
Each list element of LIST is passed to `general-define-key' as arguments."
  (mapcar
   (lambda (arg)
     `(general-define-key
       ,@arg))
   list))

(defun mic-filter-general-define-key (plist)
  "Append sexp from value of :general-define-key to value of :eval on PLIST.
Sexp is generated by `mic-make-sexp-general-define-key'."
  (mic-plist-put-append plist :eval
                        (mic-make-sexp-general-define-key
                         (plist-get plist :general-define-key)))
  (mic-plist-delete plist :general-define-key)
  plist)



(defun mic-filter-hydra (plist)
  "Create `defhydra' sexp from PLIST and append to value of `:eval'.
This filter use `:hydra' keyword."
  (mic-plist-put-append
   plist :eval
   (mapcar
    (lambda (arg)
      `(defhydra ,@arg))
    (plist-get plist :hydra)))
  (mic-plist-delete plist :hydra))

(defun mic-filter-mode-hydra (plist)
  "Create `major-mode-hydra-define' sexp from PLIST and append to value of `:eval'.
This filter use `:mode-hydra' keyword."
  (mic-plist-put-append
   plist :eval
   (mapcar
    (lambda (arg)
      `(major-mode-hydra-define ,@arg))
    (plist-get plist :mode-hydra)))
  (mic-plist-delete plist :mode-hydra))

(defun mic-filter-mykie (plist)
  "Create `mykie:define-key' sexp from PLIST and append to value of `:eval'.
This filter use `:mykie' keyword."
  (mic-plist-put-append
   plist :eval
   (cl-mapcan
    (lambda (keymap-binds-alist)
      (let ((keymap (car keymap-binds-alist))
            (binds (cdr keymap-binds-alist)))
        (mapcar
         (lambda (bind)
           (let ((key (car bind))
                 (args (cdr bind)))
             `(mykie:define-key ,keymap ,key ,@args)))
         binds)))
    (plist-get plist :mykie)))
  (mic-plist-delete plist :mykie))

(defun mic-filter-pretty-hydra (plist)
  "Create `pretty-hydra-define' sexp from PLIST and append to value of `:eval'.
This filter use `:pretty-hydra' keyword."
  (mic-plist-put-append
   plist :eval
   (mapcar
    (lambda (arg)
      `(pretty-hydra-define ,@arg))
    (plist-get plist :pretty-hydra)))
  (mic-plist-delete plist :pretty-hydra))

(defun mic-filter-pretty-hydra+ (plist)
  "Create `pretty-hydra-define+' sexp from PLIST and append to value of `:eval'.
This filter use `:pretty-hydra+' keyword."
  (mic-plist-put-append
   plist :eval
   (mapcar
    (lambda (arg)
      `(pretty-hydra-define+ ,@arg))
    (plist-get plist :pretty-hydra+)))
  (mic-plist-delete plist :pretty-hydra+))

(provide 'mic-filter)
;;; mic-filter.el ends here
