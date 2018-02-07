;; .emacs

(add-to-list 'load-path (concat (getenv "HOME") "/elisp"))

(add-to-list 'auto-mode-alist '("\\.js\\'" . javascript-mode))
(autoload 'javascript-mode "javascript" nil t)

;; The following lines are always needed. Choose your own keys.
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(add-hook 'org-mode-hook 'turn-on-font-lock) ; not needed when global-font-lock-mode is on
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(autoload 'extempore-mode "/home/felix/extempore/extras/extempore.el" "" t)
(autoload 'extempore-repl "/home/felix/extempore/extras/extempore.el" "" t)
(add-to-list 'auto-mode-alist '("\\.xtm$" . extempore-mode))

;; https://melpa.org/#/getting-started
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
        (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

(require 'linum)
(require 'hideshow)

;; turn on font-lock mode
(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t))

;; http://stackoverflow.com/questions/270772/can-i-use-cperl-mode-with-perl-mode-colorization
(custom-set-faces
 '(cperl-array-face ((t (:weight normal))))
 '(cperl-hash-face ((t (:weight normal))))
)

;; enable visual feedback on selections
(setq transient-mark-mode t)

;; default to better frame titles
(setq frame-title-format
      (concat  "%b - emacs@" system-name))

;; disable vc-git and friends
(setq vc-handled-backends nil)

;; coding standards
(eval-after-load "perl-mode"
  '(progn
     (setq perl-indent-level 4)
     )
  )

(eval-after-load "c-perl-mode"
  '(progn
     (setq perl-indent-level 4)
     )
  )

(defun perltidy-region ()
    "Run perltidy on the current region."
    (interactive)
    (save-excursion
      (shell-command-on-region (point) (mark) "perltidy -q" nil t)))
(defun perltidy-defun ()
    "Run perltidy on the current defun."
    (interactive)
    (save-excursion (mark-defun)
    (perltidy-region)))

;; turn on mouse wheel
(if (and (>= emacs-major-version 24) (window-system))
    (mouse-wheel-mode t))

;; scp when editing remote files
(setq tramp-default-method "ssh")

(require 'cl)

;; Insert spaces instead of tabs
(setq-default indent-tabs-mode nil)

;; Set line width to 78 columns
(setq fill-column 78)
(setq auto-fill-mode t)
(setq column-number-mode t)

(put 'narrow-to-page 'disabled nil)

(require 'whitespace)
(setq whitespace-space 'underline)

;; Hide Show
(setq hs-toggle-status nil)
(defun hs-toggle-all ()
  (interactive)
  (if (eq hs-toggle-status nil)
        (progn (hs-hide-all) (setq hs-toggle-status t) )
        (progn (hs-show-all) (setq hs-toggle-status nil) ) ) )

(global-set-key "\M-g" 'goto-line)
(global-set-key "\M-p" 'perltidy-region)
(global-set-key "\M-h" 'hs-hide-block)
(global-set-key "\M-s" 'hs-show-block)
(global-set-key "\M-a" 'hs-toggle-all)

(show-paren-mode t)

(put 'narrow-to-region 'disabled nil)

(defun perl-syntax-get-syntax-error-line ()
  (save-excursion
      (set-buffer "*Shell Command Output*")
      (goto-char (point-min))
      (if (looking-at ".*line \\([0-9]+\\)")
          (string-to-number (match-string-no-properties 1))
        nil)))

(defun perl-syntax-check ()
    "Checks to see if your perl program compiles"
    (interactive)

    (save-excursion
      (shell-command-on-region (goto-char (point-min)) (goto-char
(point-max)) "perl -cW"))

    (setq syntax-error-line (perl-syntax-get-syntax-error-line))
    (if syntax-error-line
        (progn
          (goto-char (point-min))
          (goto-line (perl-syntax-get-syntax-error-line))
          (set-buffer "*Shell Command Output*")
          (message (buffer-string)))))

;; Remember where I've been...
(setq save-place-file (concat (getenv "HOME") "/.emacs.d/saveplace")) ;; keep my ~/ clean
(setq-default save-place t)                   ;; activate it for all buffers
(require 'saveplace)                          ;; get the package

;; Ediff colors
(add-hook 'ediff-load-hook
          (lambda ()
            (set-face-foreground
             ediff-current-diff-face-B "blue")
            (set-face-background
             ediff-current-diff-face-B "red")
            (make-face-italic
             ediff-current-diff-face-B)))

;; File types
(setq auto-mode-alist (cons '("\\.tt$" . sgml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.conf$" . sgml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.t$" . perl-mode) auto-mode-alist))

(eval-after-load "sql"
  '(load-library "sql-indent"))

; auto completion
;;;;;;;;;;;;;;;;;
(require 'dabbrev)
(setq dabbrev-always-check-other-buffers t)
(setq dabbrev-abbrev-char-regexp "\\sw\\|\\s_")

(global-set-key "\C-i" 'my-tab)

(defun my-tab (&optional pre-arg)
  "If preceeding character is part of a word then dabbrev-expand,
else if right of non whitespace on line then tab-to-tab-stop or
indent-relative, else if last command was a tab or return then dedent
one step, else indent 'correctly'"
  (interactive "*P")
  (cond ((= (char-syntax (preceding-char)) ?w)
         (let ((case-fold-search t)) (dabbrev-expand pre-arg)))
        ((> (current-column) (current-indentation))
         (indent-relative))
        (t (indent-according-to-mode)))
  (setq this-command 'my-tab))

(add-hook 'html-mode-hook
          '(lambda ()
             (local-set-key "\C-i"     'my-tab)))
(add-hook 'sgml-mode-hook
          '(lambda ()
             (local-set-key "\C-i"     'my-tab)))
(add-hook 'perl-mode-hook
          '(lambda ()
             (local-set-key "\C-i"     'my-tab)))
(add-hook 'text-mode-hook
          '(lambda ()
             (local-set-key "\C-i"     'my-tab)))

;; No menus please
(menu-bar-mode 0)

(custom-set-variables
  ;; custom-set-variables was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(ediff-highlight-all-diffs t)
 '(ediff-use-faces nil)
 '(tab-stop-list (quote (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84)))
 '(tab-width 4))
(custom-set-faces
  ;; custom-set-faces was added by Custom -- don't edit or cut/paste it!
  ;; Your init file should contain only one such instance.
 '(ediff-current-diff-face-A ((t (:foreground "blue" :weight bold))))
 '(ediff-current-diff-face-B ((t (:foreground "red" :slant italic :weight bold))))
 '(ediff-current-diff-face-C ((((class color)) (:foreground "Pink"))))
 '(ediff-even-diff-face-A ((((class color)) (:foreground "blue"))))
 '(ediff-even-diff-face-Ancestor ((((class color)) nil)))
 '(ediff-even-diff-face-B ((t (:foreground "yellow"))))
 '(ediff-fine-diff-face-A ((((class color)) (:foreground "red" :weight bold))))
 '(ediff-fine-diff-face-B ((((class color)) (:foreground "red" :weight bold))))
 '(ediff-fine-diff-face-C ((((class color)) (:foreground "Black"))))
 '(ediff-odd-diff-face-A ((((class color)) (:foreground "blue"))))
 '(ediff-odd-diff-face-B ((((class color)) (:foreground "yellow"))))
 '(mode-line ((t (:background "magenta" :foreground "orange")))))

(defun comment-dwim-line (&optional arg)
        "Replacement for the comment-dwim command.
        If no region is selected and current line is not blank and we are not at the end of the line,
        then comment current line.
        Replaces default behaviour of comment-dwim, when it inserts comment at the end of the line."
          (interactive "*P")
          (comment-normalize-vars)
          (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
              (comment-or-uncomment-region (line-beginning-position) (line-end-position))
            (comment-dwim arg)))
(global-set-key "\M-;" 'comment-dwim-line)

;; http://stackoverflow.com/questions/4987760/how-to-change-size-of-split-screen-emacs-windows
;; http://stackoverflow.com/a/15186248/1799189
(global-set-key (kbd "<C-up>") 'shrink-window)
(global-set-key (kbd "<C-down>") 'enlarge-window)
(global-set-key (kbd "<C-left>") 'shrink-window-horizontally)
(global-set-key (kbd "<C-right>") 'enlarge-window-horizontally)


;; https://stackoverflow.com/questions/12292239/insert-the-output-of-shell-command-into-emacs-buffer
(global-set-key (kbd "C-c C-d") (lambda () (interactive) (insert (shell-command-to-string
                                                                  "date |tr -d \"\n\""))))
