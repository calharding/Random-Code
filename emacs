;; Emacs Load Path
(add-to-list 'load-path "~/elisp")

;; Remove annoying fucking menubar
(menu-bar-mode -1)

;; Use Text Mode by default for new buffers
(setq default-major-mode 'text-mode)

;; Turn on Auto Fill automatically for Text Mode and related modes
(add-hook 'text-mode-hook
	  '(lambda () (auto-fill-mode 1)))

;; Enable disabled commands (aka, livin' on the edge)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; ========== Line by line scrolling ==========
;; This makes the buffer scroll by only a single line when the up or
;; down cursor keys push the cursor (tool-bar-mode) outside the
;; buffer. the standard emacs behaviour is to reposition the cursor in
;; the center of the screen, but this can make the scrolling confusing
(setq scroll-step 1)

;; Show line number in the mode line
(line-number-mode 1)
;; Show column number in the mode line
(column-number-mode 1)

;; C indent style that conforms to the incredibly strict KNF standard.
;; Preferred style for BSD kernel source.
;; See man style(9)
(defconst knf-c-style
  '((c-basic-offset . 8)
    (c-indent-level . 8)
    (c-continued-statement-offset . 8)
    (c-brace-offset . -8)
    (c-argdecl-indent . 8)
    (c-label-offset . -8)
    (c-offsets-alist . ((knr-argdecl-intro . +)
			(knr-argdecl . 0)
			(block-open . -)
			(label . -)
			(statement-cont . 4)
			(arglist-cont . 4)
			(arglist-cont-nonempty 4))))
  "BSD KNF")

(c-add-style "knf" knf-c-style)
(custom-set-variables
 '(c-default-style "knf"))
  
;; Make % show matching parenthesis. If not over a parenthesis, simply insert %
(global-set-key "%" 'match-paren)

(defun match-paren (arg)
  "Go to the matching paren if on a paren;; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
	((looking-at "\\s\)") (forward-char 1) (backward-list 1))
	(t (self-insert-command (or arg 1)))))

;; Want dot-mode enabled all the time
(require 'dot-mode)
(add-hook 'find-file-hooks 'dot-mode-on)
(global-set-key "\C-x." 'dot-mode-execute)

;; For ibuffer mode (powerful as fuck Buffer Menu replacement)
(global-set-key (kbd "C-x C-b") 'ibuffer)
(autoload 'ibuffer "ibuffer" "List buffers." t)

;; The below is for Iswitch Buffers. Use either this or IDO

;; ;; For Iswitch Buffers (good name-based switching)
;; (iswitchb-mode 1)

;; ;; Hide some Iswitch buffers
;; ;(add-to-list 'iswitchb-buffer-ignore "^\\*")
;; (add-to-list 'iswitchb-buffer-ignore "^ ")
;; (add-to-list 'iswitchb-buffer-ignore "*Messages*")
;; (add-to-list 'iswitchb-buffer-ignore "*Buffer*")
;; (add-to-list 'iswitchb-buffer-ignore "*Ibuffer*")
;; (add-to-list 'iswitchb-buffer-ignore "*Completions*")

;; Interactively Do Things
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t) ;; enable fuzzy matching

;; Make tab in C mode just insert a tab if point is in the middle of a line.
(setq c-tab-always-indent nil)

;; Don't display the "Welcome to GNU Emacs' buffer on startup
(setq inhibit-startup-message t)

;; Hilight selection
(transient-mark-mode t)

;; make all "yes or no" prompts show "y or n" instead
(fset 'yes-or-no-p 'y-or-n-p)

;; Don't insert instructions in *scratch* buffer
(setq initial-scratch-message nil)