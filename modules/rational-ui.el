;;; rational-ui.el -*- lexical-binding: t; -*-

;; Copyright (C) 2022
;; SPDX-License-Identifier: MIT

;; Author: System Crafters Community

;; Commentary

;; User interface customizations. Examples are the modeline and how
;; help buffers are displayed.

;; This package provides a basic, customized appearance for
;; Emacs. Specifically, it uses: Helpful to customize the information
;; and visual display of help buffers, such as that created by M-x
;; `describe-function'; Doom Modeline and Themes, to customize the
;; appearance of buffers, text, et cetera; All-the-icons, to provide
;; Doom Modeline with font-based icons (rather than raster or vector
;; images); and includes some Emacs Lisp demonstrations.

;;  Run `all-the-icons-install-fonts' to ensure the fonts necessary
;; for ALL THE ICONS are available on your system. You must run this
;; function if the "stop" icon at the beginning of this paragraph is
;; not displayed properly (it appears as a box with some numbers
;; and/or letters inside it).

;; Read the documentation for `all-the-icons'; on Windows,
;; `all-the-icons-install-fonts' only downloads fonts, they must be
;; installed manually. This is necessary if icons are not displaying
;; properly.

;;; Code:

(rational-package-install-package 'all-the-icons)
(rational-package-install-package 'doom-modeline)
(rational-package-install-package 'elisp-demos)
(rational-package-install-package 'helpful)

;;;; Font
(defun rational-ui--set-default-font (spec)
  "Set the default font based on SPEC.

SPEC is expected to be a plist with the same key names
as accepted by `set-face-attribute'."
  (when spec
    (apply 'set-face-attribute 'default nil spec)))


(defgroup rational-ui '()
  "User interface related configuration for Rational Emacs."
  :tag "Rational UI"
  :group 'rational)

(defcustom rational-ui-default-font nil
  "The configuration of the `default' face.
Use a plist with the same key names as accepted by `set-face-attribute'."
  :group 'rational-ui
  :type '(plist :key-type: symbol)
  :tag "Default font"
  :set (lambda (sym val)
         (let ((prev-val (if (boundp 'rational-ui-default-font)
                             rational-ui-default-font
                         nil)))
         (set-default sym val)
         (when (and val (not (eq val prev-val)))
           (rational-ui--set-default-font val)))))

;;;; Mode-Line

;; Start up the modeline after initialization is finished
(add-hook 'after-init-hook 'doom-modeline-mode)

;; Configure `doom-modeline'
(customize-set-variable 'doom-modeline-height 15)
(customize-set-variable 'doom-modeline-bar-width 6)
(customize-set-variable 'doom-modeline-minor-modes t)
(customize-set-variable 'doom-modeline-buffer-file-name-style 'truncate-except-project)

;;;; Help Buffers

;; Make `describe-*' screens more helpful
(require 'helpful)
(define-key helpful-mode-map [remap revert-buffer] #'helpful-update)
(global-set-key [remap describe-command] #'helpful-command)
(global-set-key [remap describe-function] #'helpful-callable)
(global-set-key [remap describe-key] #'helpful-key)
(global-set-key [remap describe-symbol] #'helpful-symbol)
(global-set-key [remap describe-variable] #'helpful-variable)
(global-set-key (kbd "C-h F") #'helpful-function)

;; Bind extra `describe-*' commands
(global-set-key (kbd "C-h K") #'describe-keymap)

;;;; Line Numbers

(defcustom rational-ui-line-numbers-enabled-modes
  '(conf-mode prog-mode)
  "Modes which should display line numbers."
  :type 'list
  :group 'rational-ui)

(defcustom rational-ui-line-numbers-disabled-modes
  '(org-mode)
  "Modes which should not display line numbers.
Modes derived from the modes defined in
`rational-ui-line-number-enabled-modes', but should not display line numbers."
  :type 'list
  :group 'rational-ui)

(defun rational-ui--enable-line-numbers-mode ()
  "Turn on line numbers mode.

Used as hook for modes which should display line numbers."
  (display-line-numbers-mode 1))

(defun rational-ui--disable-line-numbers-mode ()
  "Turn off line numbers mode.

Used as hook for modes which should not display line numebrs."
  (display-line-numbers-mode -1))

(defun rational-ui--update-line-numbers-display ()
  "Update configuration for line numbers display."
  (if rational-ui-display-line-numbers
      (progn
        (dolist (mode rational-ui-line-numbers-enabled-modes)
          (add-hook (intern (format "%s-hook" mode))
                    #'rational-ui--enable-line-numbers-mode))
        (dolist (mode rational-ui-line-numbers-disabled-modes)
          (add-hook (intern (format "%s-hook" mode))
                    #'rational-ui--disable-line-numbers-mode))
        (setq-default
         display-line-numbers-grow-only t
         display-line-numbers-type t
         display-line-numbers-width 2))
     (progn
       (dolist (mode rational-ui-line-numbers-enabled-modes)
         (remove-hook (intern (format "%s-hook" mode))
                      #'rational-ui--enable-line-numbers-mode))
       (dolist (mode rational-ui-line-numbers-disabled-modes)
         (remove-hook (intern (format "%s-hook" mode))
                      #'rational-ui--disable-line-numbers-mode)))))

(defcustom rational-ui-display-line-numbers nil
  "Whether line numbers should be enabled."
  :type 'boolean
  :group 'rational-ui
  :set (lambda (sym val)
         (set-default sym val)
         (rational-ui--update-line-numbers-display)))

;;;; Elisp-Demos

;; also add some examples
(require 'elisp-demos)
(advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update)

;; add visual pulse when changing focus, like beacon but built-in
;; from from https://karthinks.com/software/batteries-included-with-emacs/
(defun pulse-line (&rest _)
  "Pulse the current line."
  (pulse-momentary-highlight-one-line (point)))

(dolist (command '(scroll-up-command scroll-down-command
                                     recenter-top-bottom other-window))
  (advice-add command :after #'pulse-line))

(provide 'rational-ui)
;;; rational-ui.el ends here
