(setq user-full-name "Chop Tr (trchopan)"
      user-mail-address "logan1011001@gmail.com")

(setq doom-theme 'doom-one)

(setq org-directory "~/org/")

(setq display-line-numbers-type t)

(add-hook 'org-mode-hook
          (lambda () (add-hook 'after-save-hook #'org-babel-tangle :append :local))
          ;; (setq-default line-spacing 6)
          )

(setq initial-frame-alist '((top . 1) (left . 1) (width . 177) (height . 60)))

(setq +format-with-lsp nil)

(add-hook 'format-all-mode-hook 'format-all-ensure-formatter)

(use-package! lsp-volar)

(setq treemacs-follow-mode t)

(with-eval-after-load 'treemacs
  (define-key evil-treemacs-state-map "s" 'treemacs-visit-node-horizontal-split))

(map! :n "<SPC>" #'evil-avy-goto-word-0)

(setq avy-keys '(?q ?t ?e ?r ?y ?u ?o ?p
                    ?a ?s ?d ?w ?b ?n ?v
                    ?k ?l ?z ?x ?c ?j ?g
                    ?h ?f ?i ))

(setq avy-style 'pre)

(defun org-insert-clipboard-image (&optional file)
  (interactive "F")
  (shell-command (concat "pngpaste " file))
  (insert (concat "[[" file "]]"))
  (org-display-inline-images))

(map! :n "X" #'kill-current-buffer)
(map! :n "H" #'+tabs:previous-or-goto)
(map! :n "L" #'+tabs:next-or-goto)
(map! :n "`h" #'treemacs-find-file)
(define-key evil-motion-state-map "s" 'evil-substitute)
(define-key evil-motion-state-map "S" 'evil-change-whole-line)

(define-key evil-motion-state-map "C-f" nil)
(map! :n "C-f w" "*Nciw")

(evil-define-operator evil-change-without-register (beg end type _ yank-handler)
  (interactive "<R><y>")
  (evil-change beg end type ?_ yank-handler))
(define-key evil-motion-state-map "s" 'evil-change-without-register)

(evil-define-operator evil-delete-without-register (beg end type _ _2)
  (interactive "<R><y>")
  (evil-delete beg end type ?_))

(evil-define-command evil-visual-paste-without-register (count &optional register)
  "Paste over Visual selection."
  :suppress-operator t
  (interactive "P<x>")
  ;; evil-visual-paste is typically called from evil-paste-before or
  ;; evil-paste-after, but we have to mark that the paste was from
  ;; visual state
  (setq this-command 'evil-visual-paste)
  (let* ((text (if register
                   (evil-get-register register)
                 (current-kill 0)))
         (yank-handler (car-safe (get-text-property
                                  0 'yank-handler text)))
         new-kill
         paste-eob)
    (evil-with-undo
      (let* ((kill-ring (list (current-kill 0)))
             (kill-ring-yank-pointer kill-ring))
        (when (evil-visual-state-p)
          (evil-visual-rotate 'upper-left)
          ;; if we replace the last buffer line that does not end in a
          ;; newline, we use ~evil-paste-after~ because ~evil-delete~
          ;; will move point to the line above
          (when (and (= evil-visual-end (point-max))
                     (/= (char-before (point-max)) ?\n))
            (setq paste-eob t))
          (evil-delete-without-register evil-visual-beginning evil-visual-end
                                        (evil-visual-type))
          (when (and (eq yank-handler #'evil-yank-line-handler)
                     (not (eq (evil-visual-type) 'line))
                     (not (= evil-visual-end (point-max))))
            (insert "\n"))
          (evil-normal-state)
          (setq new-kill (current-kill 0))
          (current-kill 1))
        (if paste-eob
            (evil-paste-after count register)
          (evil-paste-before count register)))
      (kill-new new-kill)
      ;; mark the last paste as visual-paste
      (setq evil-last-paste
            (list (nth 0 evil-last-paste)
                  (nth 1 evil-last-paste)
                  (nth 2 evil-last-paste)
                  (nth 3 evil-last-paste)
                  (nth 4 evil-last-paste)
                  t)))))

(evil-define-command evil-paste-after-without-register (count &optional register yank-handler)
  "evil paste before without yanking"
  :suppress-operator t
  (interactive "P<x>")
  (if (evil-visual-state-p)
      (evil-visual-paste-without-register count register)
    (evil-paste-after count register yank-handler)))
(define-key evil-motion-state-map "p" 'evil-paste-after-without-register)

(setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 13)
      doom-variable-pitch-font (font-spec :family "Source Serif 4" :size 13))

(add-hook 'org-mode-hook #'+org-pretty-mode)

(custom-set-faces!
  '(org-document-title :height 1.2)
  '(outline-1 :weight extra-bold :height 1.25)
  '(outline-2 :weight bold :height 1.15)
  '(outline-3 :weight bold :height 1.12)
  '(outline-4 :weight semi-bold :height 1.09)
  '(outline-5 :weight semi-bold :height 1.06)
  '(outline-6 :weight semi-bold :height 1.03)
  '(outline-8 :weight semi-bold)
  '(outline-9 :weight semi-bold))

(setq org-fontify-quote-and-verse-blocks t)

(setq +zen-text-scale 1.396)
