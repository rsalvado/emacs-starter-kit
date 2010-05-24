;; -*-Emacs-Lisp-*-

(add-to-list 'load-path (concat dotfiles-dir "/vendor"))

;; ;; This file is designed to be re-evaled; use the variable first-time
;; ;; to avoid any problems with this.
;; (defvar first-time t
;;   "Flag signifying this is the first time that .emacs has been evaled")
;; (setq inhibit-startup-message t)

(prefer-coding-system 'utf-8)

(setq make-backup-files         nil) ; Don't want any backup files
(setq auto-save-list-file-name  nil) ; Don't want any .saves files
(setq auto-save-default         nil) ; Don't want any auto saving 

;; ;; Remove menu and scroll
;; (menu-bar-mode -1)
;; (tool-bar-mode -1)
;; (toggle-scroll-bar -1)

;; Always use spaces to indent
(setq-default indent-tabs-mode nil)

;; Changes all yes/no questions to y/n type
(fset 'yes-or-no-p 'y-or-n-p)

;; Scroll down with the cursor,move down the buffer one
;; line at a time, instead of in larger amounts.
(setq scroll-step 1)

;;(setq default-major-mode 'text-mode)

;; Alternative bindings for Alt-x
(global-set-key "\C-x\C-m" 'execute-extended-command)
(global-set-key "\C-c\C-m" 'execute-extended-command)

;; Backward kill word
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
(global-set-key "\C-c\C-k" 'kill-region)

;; rgrep
(define-key global-map [\M-f1] 'rgrep)
(define-key global-map [\M-f2] 'next-error)
(define-key global-map [\M-f3] 'previous-error)

;; ;; F keys
;; ;;(define-key global-map [f1] (switch-to-buffer "*scratch*"))
;; (require 'term)
;; (defun visit-ansi-term ()
;;   "If the current buffer is:
;;      1) a running ansi-term named *ansi-term*, rename it.
;;      2) a stopped ansi-term, kill it and create a new one.
;;      3) a non ansi-term, go to an already running ansi-term
;;         or start a new one while killing a defunt one"
;;   (interactive)
;;   (let ((is-term (string= "term-mode" major-mode))
;;         (is-running (term-check-proc (buffer-name)))
;;         (term-cmd "/bin/bash")
;;         (anon-term (get-buffer "*ansi-term*")))
;;     (if is-term
;;         (if is-running
;;             (if (string= "*ansi-term*" (buffer-name))
;;                 (call-interactively 'rename-buffer)
;;               (if anon-term
;;                   (switch-to-buffer "*ansi-term*")
;;                 (ansi-term term-cmd)))
;;           (kill-buffer (buffer-name))
;;           (ansi-term term-cmd))
;;       (if anon-term
;;           (if (term-check-proc "*ansi-term*")
;;               (switch-to-buffer "*ansi-term*")
;;             (kill-buffer "*ansi-term*")
;;             (ansi-term term-cmd))
;;         (ansi-term term-cmd)))))
;; (global-set-key (kbd "<f2>") 'visit-ansi-term)

;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
    (filename (buffer-file-name)))
    (if (not filename)
    (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
      (message "A buffer named '%s' already exists!" new-name)
    (progn
      (rename-file name new-name 1)
      (rename-buffer new-name)
      (set-visited-file-name new-name)
      (set-buffer-modified-p nil))))))

(defun move-buffer-file (dir)
  "Moves both current buffer and file it's visiting to DIR." (interactive "DNew directory: ")
  (let* ((name (buffer-name))
	 (filename (buffer-file-name))
	 (dir
          (if (string-match dir "\\(?:/\\|\\\\)$")
              (substring dir 0 -1) dir))
	 (newname (concat dir "/" name)))

    (if (not filename)
	(message "Buffer '%s' is not visiting a file!" name)
      (progn 	(copy-file filename newname 1) 	(delete-file filename) 	(set-visited-file-name newname) 	(set-buffer-modified-p nil) 	t))))

;; Swap windows
(defun transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(define-key ctl-x-4-map (kbd "t") 'transpose-windows)
(define-key global-map [f11] 'transpose-windows)

;; Ask which windows to swap
(setq swapping-buffer nil)
(setq swapping-window nil)

(defun swap-buffers-in-windows ()
  "Swap buffers between two windows"
  (interactive)
  (if (and swapping-window
           swapping-buffer)
      (let ((this-buffer (current-buffer))
            (this-window (selected-window)))
        (if (and (window-live-p swapping-window)
                 (buffer-live-p swapping-buffer))
            (progn (switch-to-buffer swapping-buffer)
                   (select-window swapping-window)
                   (switch-to-buffer this-buffer)
                   (select-window this-window)
                   (message "Swapped buffers."))
          (message "Old buffer/window killed.  Aborting."))
        (setq swapping-buffer nil)
        (setq swapping-window nil))
    (progn
      (setq swapping-buffer (current-buffer))
      (setq swapping-window (selected-window))
      (message "Buffer and window marked for swapping."))))

(global-set-key (kbd "C-c p") 'swap-buffers-in-windows)

;; Focus window, and restore previous windows
(defun th-save-frame-configuration (arg)
  "Stores the current frame configuration in register
'th-frame-config-register'. If a prefix argument is given, you
can choose which register to use."
(interactive "p")  
(let ((register 100))
    (frame-configuration-to-register register)
    (delete-other-windows)
    (message "Frame saved. Press C-x ¡ to restore.")))

(defun th-jump-to-register (arg)
  "Jumps to register 'th-frame-config-register'. If a prefix
argument is given, you can choose which register to jump to."
  (interactive "p")  
  (let ((register 100))
    (jump-to-register register)
    (message "Frame restored.")))

(global-set-key (kbd "C-x '")
                'th-save-frame-configuration)
(global-set-key (kbd "C-x ¡")
                'th-jump-to-register)

;; ;; Add color to a shell running in emacs 'M-x shell'
;; (autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
;; (add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; (put 'set-goal-column 'disabled t)

;; (put 'narrow-to-region 'disabled nil)

;; ruby-mode
(add-hook 'ruby-mode-hook
          (function (lambda ()
                      (flymake-mode)
                      (linum-mode)
                      (ruby-electric-mode)
                      )))

;; Color Themes
(add-to-list 'load-path (concat dotfiles-dir "/vendor/color-theme"))
(require 'color-theme)
(color-theme-initialize)

;; Rinari
(setq rinari-tags-file-name "TAGS")

;; Activate theme
(color-theme-arjen)

(server-start)
