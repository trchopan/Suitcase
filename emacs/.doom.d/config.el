(setq user-full-name "Chop Tr (trchopan)"
      user-mail-address "logan1011001@gmail.com")

(setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 13))
(setq doom-theme 'doom-one)

(setq org-directory "~/org/")

(setq display-line-numbers-type t)

(add-hook 'org-mode-hook
          (lambda () (add-hook 'after-save-hook #'org-babel-tangle
                          :append :local)))

(setq initial-frame-alist '((top . 1) (left . 1) (width . 177) (height . 60)))
;;(add-to-list 'initial-frame-alist '(maximized))

(setq +format-with-lsp nil)

(add-hook 'format-all-mode-hook 'format-all-ensure-formatter)

(use-package! lsp-volar)



(setq treemacs-follow-mode t)

(map! :n "<SPC>" #'evil-avy-goto-word-0)

(defun org-insert-clipboard-image (&optional file)
  (interactive "F")
  (shell-command (concat "pngpaste " file))
  (insert (concat "[[" file "]]"))
  (org-display-inline-images))

(map! :n "X" #'kill-current-buffer)
(map! :n "H" #'+tabs:previous-or-goto)
(map! :n "L" #'+tabs:next-or-goto)
(map! :n "`h" #'treemacs-find-file)
