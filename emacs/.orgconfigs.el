;;; org-configs --- Summary
;;; Commentary:
;;; These are my org configs
;;; Code:

(use-package org
  :ensure t
  :hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t))

(defun dw/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (auto-fill-mode 0)
  (visual-line-mode 1))

;; I only use org mode on .org files
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; standard keyboard shortcuts
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; These are the files that can contribute to the agenda
;;(defvar org-agenda-files);; this line added so emacs knows the next variable exists.
(setq org-agenda-files (list "~/configs/admin/planner.org"
                             "~/configs/admin/schedule.org"
                             "~/configs/admin/github_projects.org"))

(use-package org-roam
  :ensure t
  :after org
  :custom
  (org-roam-directory "~/configs/admin/org_roam/")
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :bind (:map org-mode-map
              ("C-M-i" . completion-at-point))
  :config
  (org-roam-setup))

(defvar org-agenda-time-grid)
(setq org-agenda-time-grid (quote
                             ((daily today remove-match)
                              (0900 1100 1300 1500 1700)
                              "......" "----------------")))

(defvar org-export-with-properties)
(setq org-export-with-properties '("EFFORT"))


;;(setq org-default-notes-file (list "~/configs/admin/notes.org"))

;;(setq org-duration-format (quote h:mm))
;;(setq org-clock-persist 'history)
;;(org-clock-persistence-insinuate)

(defvar org-replace-disputed-keys)
(setq org-replace-disputed_keys t)
;; Make windmove work in Org mode:
(add-hook 'org-shiftup-final-hook 'windmove-up)
(add-hook 'org-shiftleft-final-hook 'windmove-left)
(add-hook 'org-shiftdown-final-hook 'windmove-down)
(add-hook 'org-shiftright-final-hook 'windmove-right)

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "|" "DONE(d)")
              (sequence "READY(r!)" "INPROGRESS(i!)" "|"
                        "REVIEW(v!)" "WAIT(w!)" "SHIPPED(s!)")
              (sequence "PHONE(p)" "MEETING(m)" "|"))))

;; THis should let me use ctrl-c ctrl-t key to select a state above but...
(setq org-use-fast-todo-selection t)
(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("READY" :foreground "red" :weight bold)
              ("INPROGRESS" :foreground "magenta" :weight bold)
              ("DONE" :foreground "blue" :weight bold)
              ("WAIT" :foreground "forestgreen" :weight bold)
              ("REVIEW" :foreground "forestgreen" :weight bold)
              ("CANCELLED" :foreground "blue" :weight bold)
              ("MEETING" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold))))

(setq org-global-properties
      (quote
       (("Effort_ALL" . "2:00 4:00 8:00 16:00 24:00 32:00 40:00")
        ("STYLE_ALL" . "habit"))))
(setq org-columns-default-format "%60ITEM(Task)
     %10Effort(Effort){:} %10CLOCKSUM")

(setq org-directory "~/phhewson_configs/admin")
(setq org-default-notes-file "~/configs/admin/refile.org")

;; I use C-c c to start capture mode
(global-set-key (kbd "C-c c") 'org-capture)

;; Capture templates for: TODO tasks, Notes,
;; appointments, phone calls, meetings, and org-protocol
(defvar org-capture-templates)
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/configs/admin/refile.org")
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
              ("r" "respond" entry (file "~/configs/admin/refile.org")
               "* NEXT Respond to %:from on
 %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t
 :clock-resume t :immediate-finish t)
              ("n" "note" entry (file "~/configs/admin/refile.org")
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("j" "Journal" entry (file+datetree
                                    "~/configs/admin/journal.org")
               "* %?\n%U\n" :clock-in t :clock-resume t)
              ("m" "Meeting" entry (file "~/configs/admin/refile.org")
               "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
              ("p" "Phone call" entry (file
                                       "~/configs/admin/refile.org")
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
	      )))


; Targets include this file and any file contributing to the agenda - up to 9 levels deep
(defvar org-refile-targets)
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))

; Use full outline paths for refile targets - we file directly with IDO
(defvar org-refile-use-outline-path)
(setq org-refile-use-outline-path t)

; Allow refile to create parent tasks with confirmation
(defvar org-refile-allow-creating-parent-nodes)
(setq org-refile-allow-creating-parent-nodes (quote confirm))


(defvar org-babel-python-command)
(setq org-babel-python-command "python3")
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t))) ; this line activates ditaa
(defvar org-ditaa-jar-path)
(setq org-ditaa-jar-path "~/configs/admin/ditaa0_9.jar")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((dot . t)))


(define-key global-map "\C-ca" 'org-agenda)
(defvar org-agenda-show-all-dates)
(setq org-agenda-show-all-dates nil)

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Replace list hyphen with dot
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                          (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(dolist (face '((org-level-1 . 1.2)
                (org-level-2 . 1.1)
                (org-level-3 . 1.05)
                (org-level-4 . 1.0)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "DejaVu Sans" :weight 'regular :height (cdr face)))

;; Make sure org-indent face is available
(require 'org-indent)

(set-face-attribute 'fixed-pitch nil
                    :family "DejaVu Sans Mono"
                    :height 120) ;; Adjust font fa

;; Ensure that anything that should be fixed-pitch in Org files appears that way
(with-eval-after-load 'org
(set-face-attribute 'org-table nil :inherit 'fixed-pitch)
(set-face-attribute 'org-block nil :foreground 'unspecified :inherit 'fixed-pitch)
(set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
(set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)
)


(use-package org-ref
  :ensure t
  :init
  (setq reftex-default-bibliography '("~/configs/admin/papers/regression.bib"))
  (setq org-ref-bibliography-notes "~/configs/admin/notes.org"
        org-ref-default-bibliography '("~/configs/admin/papers/regression.bib")
        org-ref-pdf-directory "~/Documents/papers"
	org-ref-bibtex-pdf-download-dir "~/Documents/papers")
  :config
  (require 'org-ref)
  (setq org-ref-completion-library 'org-ref-ivy-cite))

(setq bibtex-completion-pdf-open-function 'org-open-file)

;; Install and configure ivy-bibtex
(use-package ivy-bibtex
  :ensure t
  :bind ("C-c b" . ivy-bibtex)
  :init
  (setq bibtex-completion-bibliography '("~/configs/admin/papers/regression.bib")
        bibtex-completion-library-path "~/Documents/papers/"
        bibtex-completion-notes-path "~/configs/admin/notes.org"
        bibtex-completion-pdf-field "file")
  :config
  (setq ivy-bibtex-default-action 'ivy-bibtex-insert-citation
        ivy-bibtex-quick-add-keys t))

(use-package pdf-tools
  :ensure t)

;; One candidate key binding
;;(global-set-key (kbd "C-c r p") 'org-ref-pdf-to-bibtex)

;; Optional: Configure additional settings for org-ref
(setq org-ref-get-pdf-filename-function 'org-ref-get-pdf-filename-ivy-bibtex
      org-ref-notes-function 'org-ref-notes-function-one-file)

(use-package gscholar-bibtex
  :ensure t
  :custom
  (gscholar-bibtex-default-source "Google Scholar")
  (gscholar-bibtex-database-file "~/configs/admin/papers/regression.bib"))

(provide '.orgconfigs)
;;; .orgconfigs.el ends here
