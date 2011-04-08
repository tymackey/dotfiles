;;; init.el
;;
;; cpence's emacs configuration
;;
;; N.B.: This is designed for Emacs 24 nightly builds; YMMV on Emacs 23
;; and earlier.
;;

;; Lisp path
(let ((default-directory (concat user-emacs-directory "site-lisp/")))
  (normal-top-level-add-to-load-path '("."))
  (normal-top-level-add-subdirs-to-load-path))

;; Local lisp pieces
(load (concat user-emacs-directory "platforms.el"))
(load (concat user-emacs-directory "fullscreen.el"))
(load (concat user-emacs-directory "untitled.el"))


;; Themes path
(add-to-list 'custom-theme-load-path (concat user-emacs-directory "themes"))

;; Executable path (and PATH)
(push "/usr/local/bin" exec-path)
(setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
(if (system-type-is-darwin)
    (progn
      (push "/usr/texbin" exec-path)
      (setenv "PATH" (concat "/usr/texbin:" (getenv "PATH")))))

;; Custom path
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file)

;; Recent files path
(require 'recentf)
(setq recentf-save-file "~/.emacs.d/recentf"
      recentf-max-saved-items 500
      recentf-menu-items 60)
(recentf-mode t)


;; ----------------------------------------------------
;; Load all external packages

;; auctex (currently CVS 20110402)
(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)

;; darkroom-mode (currently HG 20100708, patched to use my personal
;; cp-toggle-fullscreen function)
(require 'darkroom-mode)

;; Tab bar mode (CVS from Debian, patched extensively)
(dolist (func '(tabbar-mode tabbar-forward-tab tabbar-forward-group tabbar-backward-tab tabbar-backward-group))
  (autoload func "tabbar" "Tabs at the top of buffers and easy control-tab navigation"))
(tabbar-mode 1)

;; ----------------------------------------------------
;; Emacs GUI

;; Disable splash screen
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)

;; Quick y/n prompts
(fset 'yes-or-no-p 'y-or-n-p)

;; Disable menubar if in the terminal
(if (not window-system) (menu-bar-mode -1) (menu-bar-mode 1))

;; Disable scroll bar, tool bar, fringe, tooltips
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(tooltip-mode -1)

;; Line and column numbers
(line-number-mode t)
(column-number-mode t)

;; Make the region and cursor act like they should
(delete-selection-mode t)
(blink-cursor-mode nil)

;; Set the default GUI size
(if window-system
    (setq default-frame-alist
	  '(
	    (width             . 90)
	    (height            . 35)
	    (left              . 100)
	    (top               . 24)
	    (cursor-type       . bar)
	    )
	  )
)

;; Show parens
(show-paren-mode t)

;; All tabs in one group, and don't show tabs for special Emacs buffers
(setq tabbar-buffer-groups-function
      (lambda () (list "All Buffers")))
(setq tabbar-buffer-list-function
      (lambda ()
	(remove-if
	 (lambda(buffer)
	   (find (aref (buffer-name buffer) 0) " *"))
	 (buffer-list))))

;; ----------------------------------------------------
;; File saving

;; Don't make backups
(setq make-backup-files nil)
(setq auto-save-list-file-prefix nil)
(setq auto-save-default nil)
(setq delete-auto-save-files t)

;; Save files in UTF-8 unless told otherwise
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-input-method nil)

;; Deal correctly with newlines
(setq next-line-add-newlines nil)
(setq require-final-newline t)

;; ----------------------------------------------------
;; Fonts and Colors

;; Load color theme
(load-theme 'Railscasts)

;; Enable maximum font-lock goodness
(if window-system
    (progn
      (setq font-lock-support-mode 'jit-lock-mode)
      (setq jit-lock-stealth-time 1)
      (setq font-lock-maximum-decoration t)
      (add-hook 'after-init-hook
		(global-font-lock-mode t))))

;; Highlight current line
(if window-system
    (global-hl-line-mode 1))

;; Set font
(if window-system
    (set-frame-font "Panic Sans-14:antialias=subpixel"))

;; ----------------------------------------------------
;; Keys

;; Set the OS X command-key to Control
(if (system-type-is-darwin)
    (setq mac-command-modifier 'ctrl)
)

;; Set a bunch of things to emulate TextMate/Mac programs
(global-set-key (kbd "C-l") 'goto-line)
(global-set-key (kbd "C-{") 'tabbar-backward-tab)
(global-set-key (kbd "C-}") 'tabbar-forward-tab)

;; WriteRoom emulation on F11
(global-set-key [f11] 'darkroom-mode)

;; ----------------------------------------------------
;; TeX mode configuration
(defun cpence-latex-mode-hook ()
  (interactive)
  
  ;; Set output view to call 'open' on Mac
  (if (system-type-is-darwin)
      (progn
	(setq TeX-view-program-list (quote (("open" "open %o"))))
	(setq TeX-view-program-selection (quote ((output-pdf "open") (output-html "open"))))))
  
  ;; Add BuildTex script
  (add-to-list 'TeX-command-list '("XeLaTeX" "%`xelatex -output-driver='xdvipdfmx -q -E'%(mode)%' %t" TeX-run-LaTeX nil t))
  (add-to-list 'TeX-command-list '("BuildTeX" "~/bin/buildtex %t" TeX-run-LaTeX nil t))
  (setq TeX-command-default "BuildTeX")
  
  ;; BuildTex is making PDF files
  (TeX-PDF-mode 1)
  
  ;; Curly quotes support
  (font-latex-add-quotes '("“" "”"))
)

(add-hook 'LaTeX-mode-hook 'cpence-latex-mode-hook)

