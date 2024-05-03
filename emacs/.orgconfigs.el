;; org mode
;;(make-frame-command)
;;(split-window-below)
;;(split-window-right)
;;(other-window 2)
;;(split-window-right)

;; I only use org mode on .org files
(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

;; standard keyboard shortcuts
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

;; These are the files that can contribute to the agenda
(setq org-agenda-files (list "~/configs/admin/planner.org"
                             "~/configs/admin/schedule.org"
                             "~/configs/admin/github_projects.org"
                             "~/configs/admin/asana.org")) 

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory "~/configs/admin/org_roam/")
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
	 ("C-c n f" . org-roam-node-find)
	 ("C-c n i" . org-roam-node-insert)
	 :map org-mode-map
	 ("C-M-i" . completion-at-point))
  :config
  (org-roam-setup)
  )


(setq org-agenda-time-grid (quote
                             ((daily today remove-match)
                              (0900 1100 1300 1500 1700)
                              "......" "----------------")))


(setq org-export-with-properties '("EFFORT"))


;;(setq org-default-notes-file (list "~/configs/admin/notes.org"))

(setq asana-tasks-org-file "~/configs/admin/asana.org")

;;(setq org-duration-format (quote h:mm))
;;(setq org-clock-persist 'history)
;;(org-clock-persistence-insinuate)

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
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))

; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path t)

; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))


(setq org-babel-python-command "python3")
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t))) ; this line activates ditaa
(setq org-ditaa-jar-path "~/configs/admin/ditaa0_9.jar")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((dot . t)))


(define-key global-map "\C-ca" 'org-agenda)
(setq org-agenda-show-all-dates nil)

(use-package org-journal
  :ensure t)
(setq org-journal-file-type 'monthly)
(defun org-journal-file-header-func (time)
  "Custom function to create journal header."
  (concat
    (pcase org-journal-file-type
      (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
      (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
      (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
      (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))

(setq org-journal-file-header 'org-journal-file-header-func)


