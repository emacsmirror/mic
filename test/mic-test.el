;;; mic-test.el --- Test for mic

;; Copyright (C) 2022  ROCKTAKEY

;; Author: ROCKTAKEY <rocktakey@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Test for mic

;;; Code:

(require 'ert)

(require 'undercover)
(undercover "*.el"
            (:report-format 'codecov)
            (:report-file "coverage-final.json")
            (:send-report nil))

(require 'mic)

(defmacro mic-ert-macroexpand-1 (name &rest args)
  "Define test named NAME.
The test compare macro expandation of `car' of each element of ARGS with `cdr' of it.
The test defined by this expands macro once."
  (declare (indent defun))
  `(ert-deftest ,name ()
     ,@(mapcar
        (lambda (arg)
          `(should (equal (macroexpand-1 ',(car arg))
                          ',(cdr arg))))
        args)))

(defmacro mic-ert-macroexpand-2 (name &rest args)
  "Define test named NAME.
The test compare macro expandation of `car' of each element of ARGS with `cdr' of it.
The test defined by this expands macro twice."
  (declare (indent defun))
  `(ert-deftest ,name ()
     ,@(mapcar
        (lambda (arg)
          `(should (equal (macroexpand-1 (macroexpand-1 ',(car arg)))
                          ',(cdr arg))))
        args)))



(mic-ert-macroexpand-1 mic-deffilter-validate
  ((mic-deffilter-validate filter-name
     "docstring"
     :keyword1
     :keyword2
     :keyword3)
   . (defun filter-name
         (plist)
       "docstring"
       (let (result)
         (while plist
           (let ((key (pop plist))
                 (value (pop plist)))
             (if (not
                  (memq key (append
                             '(:keyword1 :keyword2 :keyword3)
                             '(:name))))
               (warn "`mic' %s: The keyword %s is not allowed by filter `%s'"
                     (plist-get plist :name) key 'filter-name)
               (push key result)
               (push value result))))
         (nreverse result))))
  ((mic-deffilter-validate filter-name
     :keyword1
     :keyword2
     :keyword3)
   . (defun filter-name
         (plist)
       "Filter for `mic'.
It validates PLIST properties and warn if PLIST has invalid properties.
The valid properties are:
`:keyword1'
`:keyword2'
`:keyword3'"
       (let (result)
         (while plist
           (let ((key (pop plist))
                 (value (pop plist)))
             (if (not
                  (memq key (append
                             '(:keyword1 :keyword2 :keyword3)
                             '(:name))))
               (warn "`mic' %s: The keyword %s is not allowed by filter `%s'"
                     (plist-get plist :name) key 'filter-name)
               (push key result)
               (push value result))))
         (nreverse result)))))



(mic-ert-macroexpand-2 mic-autoload-interactive
  ((mic feature-name
     :autoload-interactive
     (find-file
      write-file))
   . (prog1 'feature-name
       (autoload #'find-file "feature-name" nil t)
       (autoload #'write-file "feature-name" nil t))))

(mic-ert-macroexpand-2 mic-autoload-noninteractive
  ((mic feature-name
     :autoload-noninteractive
     (cl-map
      cl-mapcar))
   . (prog1 'feature-name
       (autoload #'cl-map "feature-name")
       (autoload #'cl-mapcar "feature-name"))))

(mic-ert-macroexpand-2 mic-custom
  ((mic feature-name
     :custom
     ((a . 1)
      (b . (+ 1 2))))
   . (prog1 'feature-name
       (customize-set-variable 'a 1)
       (customize-set-variable 'b
                               (+ 1 2)))))

(mic-ert-macroexpand-2 mic-custom-after-load
  ((mic feature-name
     :custom-after-load
     ((a . 1)
      (b . (+ 1 2))))
   . (prog1 'feature-name
       (with-eval-after-load 'feature-name
         (customize-set-variable 'a 1)
         (customize-set-variable 'b
                                 (+ 1 2))))))

(mic-ert-macroexpand-2 mic-declare-function
  ((mic feature-name
     :declare-function
     (find-file
      write-file))
   . (prog1 'feature-name
       (declare-function find-file "ext:feature-name")
       (declare-function write-file "ext:feature-name"))))

(mic-ert-macroexpand-2 mic-define-key
  ((mic feature-name
     :define-key
     ((global-map
       ("C-t" . #'other-window)
       ("C-n" . #'next-window))
      (prog-mode-map
       ("M-a" . #'beginning-of-buffer)
       ("M-e" . #'end-of-buffer))))
   . (prog1 'feature-name
       (define-key global-map (kbd "C-t") #'other-window)
       (define-key global-map (kbd "C-n") #'next-window)
       (define-key prog-mode-map (kbd "M-a") #'beginning-of-buffer)
       (define-key prog-mode-map (kbd "M-e") #'end-of-buffer))))

(mic-ert-macroexpand-2 mic-define-key-after-load
  ((mic feature-name
     :define-key-after-load
     ((c-mode-map
       ("C-t" . #'other-window)
       ("C-n" . #'next-window))
      (c++-mode-map
       ("M-a" . #'beginning-of-buffer)
       ("M-e" . #'end-of-buffer))))
   . (prog1 'feature-name
       (with-eval-after-load 'feature-name
         (define-key c-mode-map (kbd "C-t") #'other-window)
         (define-key c-mode-map (kbd "C-n") #'next-window)
         (define-key c++-mode-map (kbd "M-a") #'beginning-of-buffer)
         (define-key c++-mode-map (kbd "M-e") #'end-of-buffer)))))

(mic-ert-macroexpand-2 mic-define-key-with-feature
  ((mic feature-name
     :define-key-with-feature
     ((cc-mode
       (c-mode-map
        ("C-t" . #'other-window)
        ("C-n" . #'next-window))
       (c++-mode-map
        ("M-a" . #'beginning-of-buffer)
        ("M-e" . #'end-of-buffer)))
      (python
       (python-mode-map
        ("C-t" . #'python-check)))))
   . (prog1 'feature-name
       (with-eval-after-load 'cc-mode
         (define-key c-mode-map (kbd "C-t") #'other-window)
         (define-key c-mode-map (kbd "C-n") #'next-window)
         (define-key c++-mode-map (kbd "M-a") #'beginning-of-buffer)
         (define-key c++-mode-map (kbd "M-e") #'end-of-buffer))
       (with-eval-after-load 'python
         (define-key python-mode-map (kbd "C-t") #'python-check)))))

(mic-ert-macroexpand-2 mic-defvar-noninitial
  ((mic feature-name
     :defvar-noninitial
     (skk-jisyo
      skk-use-azik))
   . (prog1 'feature-name
       (defvar skk-jisyo)
       (defvar skk-use-azik))))

(mic-ert-macroexpand-2 mic-eval
  ((mic feature-name
     :eval
     ((message "Hello")
      (message "World")))
   . (prog1 'feature-name
       (message "Hello")
       (message "World"))))

(mic-ert-macroexpand-2 mic-eval-after-load
  ((mic feature-name
     :eval-after-load
     ((message "Hello")
      (message "World")))
   . (prog1 'feature-name
       (with-eval-after-load 'feature-name
         (message "Hello")
         (message "World")))))

(mic-ert-macroexpand-2 mic-eval-after-others
  ((mic feature-name
     :custom
     ((skk-jisyo . "~/skk-jisyo"))
     :eval
     ((message "before")
      (message "custom"))
     :eval-after-others
     ((message "after")
      (message "custom")))
   . (prog1 'feature-name
       (message "before")
       (message "custom")
       (customize-set-variable
        'skk-jisyo
        "~/skk-jisyo")
       (message "after")
       (message "custom"))))

(mic-ert-macroexpand-2 mic-eval-after-others-after-load
  ((mic feature-name
     :custom-after-load
     ((skk-jisyo . "~/skk-jisyo"))
     :eval-after-load
     ((message "before")
      (message "custom"))
     :eval-after-others-after-load
     ((message "after")
      (message "custom")))
   . (prog1 'feature-name
       (with-eval-after-load 'feature-name
         (message "before")
         (message "custom")
         (customize-set-variable
          'skk-jisyo
          "~/skk-jisyo")
         (message "after")
         (message "custom")))))

(mic-ert-macroexpand-2 mic-eval-before-all
  ((mic feature-name
     :custom
     ((skk-jisyo . "~/skk-jisyo"))
     :eval
     ((message "before")
      (message "custom"))
     :eval-before-all
     ((message "before")
      (message "all")))
   . (prog1 'feature-name
       (message "before")
       (message "all")
       (message "before")
       (message "custom")
       (customize-set-variable
        'skk-jisyo
        "~/skk-jisyo"))))

(mic-ert-macroexpand-2 mic-face
  ((mic feature-name
     :face
     ((aw-leading-char-face
       . ((t (:foreground "red" :height 10.0))))
      (aw-mode-line-face
       . ((t (:background "#006000" :foreground "white" :bold t))))))
   . (prog1 'feature-name
       (custom-set-faces
        '(aw-leading-char-face
          ((t (:foreground "red" :height 10.0))))
        '(aw-mode-line-face
          ((t (:background "#006000" :foreground "white" :bold t))))))))

(mic-ert-macroexpand-2 mic-hook
  ((mic feature-name
     :hook
     ((after-init-hook . #'ignore)
      (prog-mode-hook . (lambda ()))))
   . (prog1 'feature-name
       (add-hook 'after-init-hook #'ignore)
       (add-hook 'prog-mode-hook (lambda ())))))

(mic-ert-macroexpand-2 mic-package
  ((mic feature-name
     :package
     (package-1
      package-2))
   . (prog1 'feature-name
       (unless (package-installed-p 'package-1)
         (package-install 'package-1))
       (unless (package-installed-p 'package-2)
         (package-install 'package-2)))))



(ert-deftest mic-plist-put ()
  (let ((plist '(:foo 1 :bar 2)))
    (mic-plist-put plist :baz 3)
    (should (eq (plist-get plist :foo) 1))
    (should (eq (plist-get plist :bar) 2))
    (should (eq (plist-get plist :baz) 3)))

  (let (plist)
    (mic-plist-put plist :baz 3)
    (should (eq (plist-get plist :baz) 3))))

(ert-deftest mic-plist-put-append ()
  (let ((plist '(:foo 1 :bar 2)))
    (mic-plist-put-append plist :baz '(3))
    (should (eq (plist-get plist :foo) 1))
    (should (eq (plist-get plist :bar) 2))
    (should (equal (plist-get plist :baz) '(3))))

  (let ((plist '(:foo (1) :bar (2))))
    (mic-plist-put-append plist :bar '(3))
    (should (equal (plist-get plist :foo) '(1)))
    (should (equal (plist-get plist :bar) '(2 3))))

  (let (plist)
    (mic-plist-put-append plist :baz '(3))
    (should (equal (plist-get plist :baz) '(3)))))

(ert-deftest mic-plist-delete ()
  (let ((plist '(:foo 1 :bar 2)))
    (mic-plist-delete plist :foo)
    (should-not (plist-get plist :foo))
    (should (eq (plist-get plist :bar) 2))
    (should (equal plist '(:bar 2))))

  (let ((plist '(:foo 1 :bar 2)))
    (mic-plist-delete plist :bar)
    (should (eq (plist-get plist :foo) 1))
    (should-not (plist-get plist :bar))
    (should (equal plist '(:foo 1))))

  (let ((plist '(:foo 1 :bar 2 :baz 3)))
    (mic-plist-delete plist :bar :foo)
    (should-not (plist-get plist :foo))
    (should-not (plist-get plist :bar))
    (should (eq (plist-get plist :baz) 3))
    (should (equal plist '(:baz 3)))))



(mic-ert-macroexpand-1 mic-deffilter-const-macroexpand-1
  ((mic-deffilter-const func-name
     :foo t
     :bar '(2 4))
   . (defun func-name (plist)
       "Filter for `mic'.
It return PLIST but each value on some property below is replaced:
(:foo t :bar
      '(2 4))
"
       (mic-plist-put plist :foo t)
       (mic-plist-put plist :bar '(2 4))
       plist))
  ((mic-deffilter-const func-name
     "docstring"
     :foo t
     :bar '(2 4))
   . (defun func-name (plist)
       "docstring"
       (mic-plist-put plist :foo t)
       (mic-plist-put plist :bar '(2 4))
       plist)))

(ert-deftest mic-deffilter-const ()
  (mic-deffilter-const mic-test-mic-deffilter-const
    :foo t
    :bar '(2 4))

  (let* ((init '(:foo 1 :bar 2))
         (result (mic-test-mic-deffilter-const init)))
    (should (equal (plist-get result :foo) t))
    (should (equal (plist-get result :bar) '(2 4)))))

(mic-ert-macroexpand-1 mic-deffilter-const-append-macroexpand-1
  ((mic-deffilter-const-append func-name
     :foo '(t)
     :bar '(2 4))
   . (defun func-name (plist)
       "Filter for `mic'.
It return PLIST but each value on some property below is appended:
(:foo
 '(t)
 :bar
 '(2 4))
"
       (mic-plist-put-append plist :foo
                              '(t))
       (mic-plist-put-append plist :bar
                              '(2 4))
       plist))
  ((mic-deffilter-const-append func-name
     "docstring"
     :foo '(t)
     :bar '(2 4))
   . (defun func-name (plist)
       "docstring"
       (mic-plist-put-append plist :foo '(t))
       (mic-plist-put-append plist :bar '(2 4))
       plist)))

(ert-deftest mic-deffilter-const-append ()
  (mic-deffilter-const-append mic-test-mic-deffilter-const-append
    :foo '(t)
    :bar '(3 4))

  (let* ((init '(:foo (1) :bar (2)))
         (result (mic-test-mic-deffilter-const-append init)))
    (should (equal (plist-get result :foo) '(1 t)))
    (should (equal (plist-get result :bar) '(2 3 4)))))

(mic-ert-macroexpand-1 mic-apply-filter
  ((mic-apply-filter plist name-var
     filter1
     filter2
     filter3)
   . (progn
       (mic-plist-put plist :name name-var)
       (setq plist
             (thread-last plist filter1 filter2 filter3))
       (mic-plist-delete plist :name))))

(mic-ert-macroexpand-1 mic-defmic-macroexpand-1
  ((mic-defmic macro-name parent-name
     "docstring"
     :filters '(filter1 filter2))
   . (defmacro macro-name (name &rest plist)
       "docstring"
       (declare (indent defun))
       (mic-apply-filter plist name
         filter1 filter2)
       (backquote
        (parent-name ,name ,@plist))))
  ((mic-defmic macro-name parent-name
     :filters '(filter1 filter2))
   . (defmacro macro-name (name &rest plist)
       "`mic' alternative defined by `mic-defmic'.
Argument NAME, PLIST. Used filters are:
- `filter1'
- `filter2'"
       (declare (indent defun))
       (mic-apply-filter plist name
         filter1 filter2)
       (backquote
        (parent-name ,name ,@plist)))))

(mic-deffilter-const-append mic-test-filter-const-1
    :foo '(1)
    :bar '(2 3))

(mic-deffilter-const-append mic-test-filter-const-2
  :foo '(4 5)
  :baz '(6 7))

(mic-defmic mic-test-mic-defmic-filters parent-name
  :filters '(mic-test-filter-const-1 mic-test-filter-const-2))

(mic-ert-macroexpand-1 mic-defmic-filters
  ((mic-test-mic-defmic-filters feature-name
     :foo (123)
     :bar (456))
   . (parent-name feature-name
                  :foo
                  (123 1 4 5)
                  :bar
                  (456 2 3)
                  :baz
                  (6 7))))

(provide 'mic-test)
;;; mic-test.el ends here
