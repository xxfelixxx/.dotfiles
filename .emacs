(defconst dot-emacs (concat (getenv "HOME") "/.emacs.felix.el")
  "My dot emacs file")

(require 'bytecomp)

(setq compiled-dot-emacs (byte-compile-dest-file dot-emacs))

(if (or (not (file-exists-p compiled-dot-emacs))
        (file-newer-than-file-p dot-emacs compiled-dot-emacs)
        (equal (nth 4 (file-attributes dot-emacs)) (list 0 0)))
    (load dot-emacs)
  (load compiled-dot-emacs))

(add-hook 'kill-emacs-hook
          '(lambda () (and (file-newer-than-file-p dot-emacs compiled-dot-emacs)
                           (byte-compile-file dot-emacs))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ediff-highlight-all-diffs t)
 '(ediff-use-faces nil)
 '(linum-format "%4d ")
 '(tab-stop-list (quote (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84)))
 '(tab-width 4))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cperl-array-face ((t (:weight normal))))
 '(cperl-hash-face ((t (:weight normal))))
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
