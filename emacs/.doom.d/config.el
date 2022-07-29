(setq user-full-name "Chop Tr (chop.ink)"
      user-mail-address "chop@chop.ink")

(setq doom-theme 'doom-tomorrow-night)

(setq org-directory "~/org")

(setq display-line-numbers-type t)

(setq standard-indent 2)

(setq evil-search-wrap t)

(defun doom-dashboard-draw-ascii-emacs-banner-fn ()
  (let* ((banner
          '("      __                          __                             "
            "     /\\ \\                        /\\ \\__                          "
            "  ___\\ \\ \\___     ___   _____    \\ \\ ,_\\  _ __    __      ___    "
            " /'___\\ \\  _ `\\  / __`\\/\\ '__`\\   \\ \\ \\/ /\\`'__\\/'__`\\  /' _ `\\  "
            "/\\ \\__/\\ \\ \\ \\ \\/\\ \\L\\ \\ \\ \\L\\ \\   \\ \\ \\_\\ \\ \\//\\ \\L\\.\\_/\\ \\/\\ \\ "
            "\\ \\____\\\\ \\_\\ \\_\\ \\____/\\ \\ ,__/    \\ \\__\\\\ \\_\\\\ \\__/.\\_\\ \\_\\ \\_\\"
            " \\/____/ \\/_/\\/_/\\/___/  \\ \\ \\/      \\/__/ \\/_/ \\/__/\\/_/\\/_/\\/_/"
            "                          \\ \\_\\                                  "
            "                           \\/_/                                  "
            "                                                                 "))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat
                 line (make-string (max 0 (- longest-line (length line)))
                                   32)))
               "\n"))
     'face 'doom-dashboard-banner)))

(setq +doom-dashboard-ascii-banner-fn #'doom-dashboard-draw-ascii-emacs-banner-fn)

(add-hook 'org-mode-hook
          (lambda () (add-hook 'after-save-hook #'org-babel-tangle :append :local)))

(if (string= (getenv "USER") "lw70868")
    (setq initial-frame-alist '((top . 1) (left . 1) (width . 190) (height . 65)))
  (setq initial-frame-alist '((top . 1) (left . 1) (width . 177) (height . 55))))

(setq-hook! 'haskell-mode-hook +format-with-lsp nil)
(setq-hook! 'typescript-mode-hook +format-with-lsp nil)

;; (add-hook 'format-all-mode-hook 'format-all-ensure-formatter)

(setq lsp-signature-auto-activate nil)

(map! :leader :desc "Show flycheck" :n "t f" (cmd! (flycheck-list-errors)))

;; (use-package! tree-sitter
;;   :config
;;   (require 'tree-sitter-langs)
;;   (global-tree-sitter-mode)
;;   (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
;;   (pushnew! tree-sitter-major-mode-language-alist
;;           '(scss-mode . css))
;;   (pushnew! tree-sitter-major-mode-language-alist
;;           '(haskell-mode . haskell)))

(defun treemacs-find-and-goto-treemacs ()
  (interactive)
  (treemacs-find-file)
  (treemacs-select-window))
(map! :n "`h" #'treemacs-find-and-goto-treemacs)

(with-eval-after-load 'treemacs
  (define-key evil-treemacs-state-map "s" 'treemacs-visit-node-horizontal-split))

(with-eval-after-load 'treemacs
  (define-key evil-treemacs-state-map (kbd "<SPC>") #'avy-goto-line))

(with-eval-after-load 'treemacs
  (define-key evil-treemacs-state-map (kbd "\\\\") #'+treemacs/toggle))

(map! :n "\\\\" #'+treemacs/toggle)

(after! doom-themes
  (setq doom-themes-treemacs-theme "doom-colors") ; use "doom-colors" for less minimal icon theme
  (doom-themes-treemacs-config))

(after! lsp-treemacs
  (load-library "doom-themes-ext-treemacs"))

(map! :leader :n "g p" #'git-gutter:popup-hunk)

(map! :n "<SPC>" #'evil-avy-goto-word-0)

(setq avy-keys '(?q ?t ?e ?r ?y ?u ?o ?p
                    ?a ?s ?d ?w ?b ?n ?v
                    ?k ?l ?z ?x ?c ?j ?g
                    ?h ?f ?i ?m))

(setq avy-style 'de-bruijn)

(add-hook 'org-mode-hook #'+org-pretty-mode)

(setq org-ellipsis " [+]")

(defun org-insert-clipboard-image (&optional file)
  (interactive "F")
  (setq filename (concat file (format-time-string "_%Y%m%d_%H%M%S") ".png"))
  (shell-command (concat "clipboard-image-paste 1280 " filename " \"png[Q=85]\""))
  (insert "#+attr_html: :width 720\n")
  (insert (concat "[[" filename "]]")))

(with-eval-after-load 'centaur-tabs
  (centaur-tabs-group-by-projectile-project))

(map! :n "H" #'+tabs:previous-or-goto)
(map! :n "L" #'+tabs:next-or-goto)
(map! :n "C-M-{" #'centaur-tabs-move-current-tab-to-left)
(map! :n "C-M-}" #'centaur-tabs-move-current-tab-to-right)
(map! :n "X" #'kill-current-buffer)

;; Need to unbind this for org-mode
(with-eval-after-load 'evil-org
  (define-key evil-org-mode-map (kbd "<normal-state> X") nil))

(define-key evil-motion-state-map "C-f" nil)
(map! :n "C-f w" "*Nciw")

(evil-define-operator evil-change-without-register (beg end type _ yank-handler)
  (interactive "<R><y>")
  (evil-change beg end type ?_ yank-handler))

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
(define-key evil-motion-state-map "s" 'evil-change-without-register)
(define-key evil-motion-state-map "c" 'evil-change-without-register)

(with-eval-after-load 'evil
  (evil-define-operator evil-change
    (beg end type register yank-handler delete-func)
    "Change text from BEG to END with TYPE.
Save in REGISTER or the kill-ring with YANK-HANDLER.
DELETE-FUNC is a function for deleting text, default `evil-delete'.
If TYPE is `line', insertion starts on an empty line.
If TYPE is `block', the inserted text in inserted at each line
of the block."
    (interactive "<R><x><y>")
    ;; (let ((delete-func (or delete-func #'evil-delete))
    (let ((delete-func (or delete-func #'evil-delete-without-register))
          (nlines (1+ (evil-count-lines beg end)))
          (opoint (save-excursion
                    (goto-char beg)
                    (line-beginning-position))))
      (unless (eq evil-want-fine-undo t)
        (evil-start-undo-step))
      (funcall delete-func beg end type register yank-handler)
      (cond
       ((eq type 'line)
        (setq this-command 'evil-change-whole-line) ; for evil-maybe-remove-spaces
        (if (= opoint (point))
            (evil-open-above 1)
          (evil-open-below 1)))
       ((eq type 'block)
        (evil-insert 1 nlines))
       (t
        (evil-insert 1)))
      (setq evil-this-register nil))))

(define-key evil-motion-state-map "s" 'evil-substitute)
(define-key evil-motion-state-map "S" 'evil-change-whole-line)

(with-eval-after-load 'evil
    (defalias #'forward-evil-word #'forward-evil-symbol)
    ;; make evil-search-word look for symbol rather than word boundaries
    (setq-default evil-symbol-word-search t))

(map! :ni "C-)" #'sp-forward-slurp-sexp)
(map! :ni "C-(" #'sp-backward-slurp-sexp)

(if (string= (getenv "USER") "lw70868")
    (setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 14)
          doom-variable-pitch-font (font-spec :family "Source Serif Pro" :size 16)
          doom-big-font (font-spec :family "FiraCode Nerd Font Mono" :size 18))
  (setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 13)
        doom-variable-pitch-font (font-spec :family "Source Serif Pro" :size 15)
        doom-big-font (font-spec :family "FiraCode Nerd Font Mono" :size 17)))

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
