;; .emacs

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-switches "-u"))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)

;;; uncomment for CJK utf-8 support for non-Asian users
;; (require 'un-define)

(define-key key-translation-map "\M-[1;2A" (kbd "S-<up>"))
(define-key key-translation-map "\M-[1;2B" (kbd "S-<down>"))
(define-key key-translation-map "\M-[1;2C" (kbd "S-<right>"))
(define-key key-translation-map "\M-[1;2D" (kbd "S-<left>"))
(define-key key-translation-map "\M-[1;2F" (kbd "S-<end>"))
(define-key key-translation-map "\M-[1;2H" (kbd "S-<home>"))

(define-key key-translation-map "\M-[1;3A" (kbd "M-<up>"))
(define-key key-translation-map "\M-[1;3B" (kbd "M-<down>"))
(define-key key-translation-map "\M-[1;3C" (kbd "M-<right>"))
(define-key key-translation-map "\M-[1;3D" (kbd "M-<left>"))
(define-key key-translation-map "\M-[1;3F" (kbd "M-<end>"))
(define-key key-translation-map "\M-[1;3H" (kbd "M-<home>"))

(define-key key-translation-map "\M-[5;3~" (kbd "M-<prior>"))
(define-key key-translation-map "\M-[6;3~" (kbd "M-<next>"))

(define-key key-translation-map "\M-[1;4A" (kbd "M-S-<up>"))
(define-key key-translation-map "\M-[1;4B" (kbd "M-S-<down>"))
(define-key key-translation-map "\M-[1;4C" (kbd "M-S-<right>"))
(define-key key-translation-map "\M-[1;4D" (kbd "M-S-<left>"))
(define-key key-translation-map "\M-[1;4F" (kbd "M-S-<end>"))
(define-key key-translation-map "\M-[1;4H" (kbd "M-S-<home>"))

(define-key key-translation-map "\M-[1;5A" (kbd "C-<up>"))
(define-key key-translation-map "\M-[1;5B" (kbd "C-<down>"))
(define-key key-translation-map "\M-[1;5C" (kbd "C-<right>"))
(define-key key-translation-map "\M-[1;5D" (kbd "C-<left>"))
(define-key key-translation-map "\M-[1;5F" (kbd "C-<end>"))
(define-key key-translation-map "\M-[1;5H" (kbd "C-<home>"))

(define-key key-translation-map "\M-[1;6A" (kbd "C-S-<up>"))
(define-key key-translation-map "\M-[1;6B" (kbd "C-S-<down>"))
(define-key key-translation-map "\M-[1;6C" (kbd "C-S-<right>"))
(define-key key-translation-map "\M-[1;6D" (kbd "C-S-<left>"))
(define-key key-translation-map "\M-[1;6F" (kbd "C-S-<end>"))
(define-key key-translation-map "\M-[1;6H" (kbd "C-S-<home>"))

(global-set-key (kbd "M-S-<left>") 'previous-buffer)
(global-set-key (kbd "M-S-<right>") 'next-buffer)

;; haskell ->
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(custom-set-variables
  '(haskell-process-suggest-remove-import-lines t)
  '(haskell-process-auto-import-loaded-modules t)
  '(haskell-process-log t))
;; <- haskell

;; ocaml ->
;;(add-hook 'tuareg-mode-hook 'tuareg-imenu-set-imenu)
(add-to-list 'load-path (concat
  (replace-regexp-in-string "\n$" ""
    (shell-command-to-string "opam config var share"))
  "/emacs/site-lisp"))
(require 'ocp-indent)

(setq auto-mode-alist
  (append '(("\\.ml[ily]?$" . tuareg-mode)
            ("\\.topml$" . tuareg-mode))
          auto-mode-alist)) 
(autoload 'utop-setup-ocaml-buffer "utop" "Toplevel for OCaml" t)
(add-hook 'tuareg-mode-hook 'utop-setup-ocaml-buffer)
(add-hook 'tuareg-mode-hook 'merlin-mode)
(setq merlin-use-auto-complete-mode t)
(setq merlin-error-after-save nil)
;; <- ocaml

;; markdown ->
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))
;; <- markdown

(cua-mode t)
(setq cua-auto-tabify-rectangles nil)
(transient-mark-mode 1)
(setq cua-keep-region-after-copy t)

(windmove-default-keybindings 'meta)
