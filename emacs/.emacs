;;; package --- summary
;;; Commentary:
;;; Code:

;; 105 key PC intnl English Default
;;(cond ((eq system-type 'windows-nt) "do somthing")
;;      ((eq system-type 'gnu/linux) "do something else")
;;      )


 (tool-bar-mode 1)


(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (c "https://github.com/tree-sitter/tree-sitter-c")
     (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (latex "https://github.com/tree-sitter/tree-sitter-latex")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (r "https://github.com/tree-sitter/tree-sitter-r")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

(setq major-mode-remap-alist
 '((c++-mode . c++-ts-mode)
   )
 )


;; set transparency
(set-frame-parameter (selected-frame) 'alpha '(85 85))
(add-to-list 'default-frame-alist '(alpha 85 85))

(setq require-final-newline t)

(use-package helm
  :ensure t)
(load-library "~/.emacs.d/elpa/asana.el")


(defun arrayify (start end quote)
    "Turn strings on newlines between START and END \
into a comma-separated one-liner surrounded by QUOTE."
    (interactive "r\nMQuote: ")
    (let ((insertion
           (mapconcat
            (lambda (x) (format "%s%s%s" quote x quote))
            (split-string (buffer-substring start end)) ", ")))
      (delete-region start end)
      (insert insertion)))

;; doing a defvar because of a linter error
;; (epa-pinentry-mode is a variable in a library)
;; do Ctrl-h v epa-pintentry-mode

(defvar epa-pinentry-mode)
(setq epa-pinentry-mode 'loopback)

(setq abbrev-file-name             ;; tell emacs where to read abbrev
       "~/configs/emacs/abbrev/.abbrev_defs")
(setq save-abbrevs 'silent)
(add-to-list 'exec-path "~/miniconda/bin")
;;(add-to-list 'exec-path "/c/mingw/bin")
(add-to-list 'load-path (expand-file-name "~/configs/misc_el/"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elpa/"))
(add-hook 'nxml-mode-hook 'abbrev-mode)

;;(require 'emamux)
(add-hook 'nxml-mode-hook
          (lambda () (add-to-list
                      'write-file-functions 'delete-trailing-whitespace)))

(setenv "TEST_DATA_HOME" "/home/phewson/analytics-queries/ci/tests/sim_data")

(find-file "~/configs/admin/planner.org")

;; default mail downloads in Downloads
(defvar mm-default-directory)
(setq mm-default-directory "~/Downloads")
;; keyboard shortcut Meta + ' provides two quotes
(global-set-key (kbd "M-\'") 'insert-pair)
;; Prevent extraneous tabs (annoying for makefiles)
(setq-default indent-tabs-mode nil)
;; make bell visible
(setq visible-bell t)
;; adds non emacs clipboard to emacs kill ring
(setq save-interprogram-paste-before-kill t)
;; remove tool bar
(tool-bar-mode 1)
;; don't have the standard start up messages
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)
;; use utf-8
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))
;; include column numbers for cursor in modeline
(setq column-number-mode t)
;; stop shell duplicating history
(defvar comint-input-ignoredups)
(setq comint-input-ignoredups t)
;; idf files handled by config mode
;;(add-to-list 'auto-mode-alist '("\\.idf\\'" . conf-mode))

;; set various environmental variables
;;(setenv "HOME" "~/")

(setenv "PGUSER" "vagrant")
(setenv "PGHOST" "localhost")
(setenv "PGDATABASE" "official")
(setenv "PGPORT" "15432")

;; package handling, and melpa

(require 'package)
(setq package-archives
   (quote
    (("melpa" . "https://melpa.org/packages/")
     ("gnu" . "https://elpa.gnu.org/packages/"))))

(package-initialize)
;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/"))

(eval-after-load 'gnutls
  '(add-to-list 'gnutls-trustfiles "/etc/ssl/cert.pem"))
(unless (package-installed-p 'use-package)
  ;;(package-list-packages)
  (package-refresh-contents)
  (package-install 'use-package)
)

(eval-when-compile
;;  ;; Following line is not needed if use-package.el is in ~/.emacs.d
 (require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

<<<<<<< HEAD
=======
;; load jinja2 mode
(use-package jinja2-mode
  :ensure t)

;;(add-to-list 'load-path "~/configs/misc_el/")
;;(load "splunk-mode.el")
(use-package splunk-mode
             :load-path "~/configs/misc_el/")
(require 'splunk-mode)
(add-to-list 'auto-mode-alist '("\\.spl\\'" . splunk-mode))
 (add-hook 'splunk-mode-hook #'abbrev-mode)

>>>>>>> 0f0234e (old file)
(use-package magit
  :ensure t)

(use-package docker
  :ensure t)

(use-package ov
  :ensure t)

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

(use-package docker-compose-mode
  :ensure t)

;; allow opening of recent files via menu or Ctrl-x Ctrl-r
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; json mode
(use-package json-mode
  :ensure t)

;; linum mode
;;(global-linum-mode t)
(global-display-line-numbers-mode)


;; whitespace mode
(use-package whitespace
  :ensure t)
;; (global-whitespace-mode)
(setq-default whitespace-line-column 101)
;; (global-whitespace-mode 1)
;;(setq whitespace-global-modes '(not org-mode))
(add-hook 'emacs-lisp-mode-hook
          (function (lambda()
                      (whitespace-mode t))))
(add-hook 'python-mode-hook
          (function (lambda()
                      (whitespace-mode t))))
(add-hook 'r-mode-hook
          (function (lambda()
                      (whitespace-mode t))))


(put 'upcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)

;; wgrep mode
(use-package wgrep
    :ensure t)

;; framemove (shift and arrow)
(use-package framemove
    :load-path "~/configs/misc_el/")
(windmove-default-keybindings)
(setq framemove-hook-into-windmove t)
;; (when (fboundp 'windmove-default-keybindings)
;;  (windmove-default-keybindings))
;; right width for liniting rules?
(add-to-list 'initial-frame-alist '(width . 101))
(add-to-list 'default-frame-alist '(width . 101))

(require 'dired-x)
(setq-default dired-omit-files-p t)
(setq dired-omit-files
      (concat dired-omit-files "\\.doc$"))
;; dired+
;;(use-package dired+
;;  :load-path "~/.emacs.d/packages/dired+")

;; Load Dired X when Dired is loaded.
;; think I prefer dired+
;; (use-package diredful "")?`
;;     :ensure t) "")?`
;; (diredful-mode 1) "")?`
;; (setq dired-omit-mode t) ;\ Turn on Omit mode. "")?`
;;  (require 'dired-x) "")?`
;;     (setq-default dired-omit-files-p t) ;\ Buffer-local variable "")?`
;;     (setq dired-omit-files (concat dired-omit-files "~*")) "")?`


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(canlock-password "b32f77f6c531a3dccdac916b000d579035630711")
 '(conda-anaconda-home "~/miniconda")
 '(custom-safe-themes
   '("80b00f3bf7cdbdca6c80aadfbbb03145f3d0aacf6bf2a559301e61109954e30a" default))
 '(elfeed-feeds
   '("https://martinfowler.com/feed.atom" "https://opensource.com/feed" "https://feeds.feedburner.com/RBloggers"))
 '(flycheck-checker-error-threshold 800)
 '(flycheck-lintr-linters "with_defaults(line_length_linter(100))")
 '(flycheck-python-flake8-executable "~/miniconda3/envs/splunk/bin/flake8")
 '(flycheck-python-mypy-executable "~/miniconda3/envs/splunk/bin/mypy")
 '(magit-log-arguments '("--graph" "--color" "--decorate" "-n256"))
 '(package-selected-packages
   '(exec-path-from-shell helm forge all-the-icons-dired all-the-icons xterm-color xresources-theme leuven-theme csv-mode sed-mode versuri ov pycoverage string-inflection sqlup-mode toggle-quotes docker docker-compose-mode ansible ansible-mode cloud-theme autumn-light-theme org-jira elfeed graphviz-dot-mode yaml-mode smartscan gitlab-ci-mode-flycheck flycheck hackernews ess bbdb hydandata-light-theme yasnippet wttrin wgrep stan-mode realgud pyvenv poly-R org-gcal json-mode htmlize google-translate gnus-desktop-notify dad-joke coverage auto-complete auctex))
 '(send-mail-function 'smtpmail-send-it))

(use-package elfeed
  :ensure t)

;; flycheck
(setq flycheck-flake8rc "~/configs/splunk/.flake8")
(use-package flycheck
     :ensure t)
(use-package flycheck-mypy
     :load-path "~/configs/misc_el")
(global-flycheck-mode)
(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'c++-mode-hook
    (lambda() (setq flycheck-gcc-include-path
       (list (expand-file-name "~/R/x86_64-pc-linux-gnu-library/4.0/testthat/include")
             (expand-file-name "~/R/x86_64-pc-linux-gnu-library/4.0/Rcpp/include"))
)))

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))

;; stack exchange hack, ubuntu has old version of shell linter
(setq flycheck-shellcheck-follow-sources nil)
(add-hook 'sh-mode-hook 'flycheck-mode)

(use-package hackernews
  :ensure t)

(setq sql-postgres-login-params
      '((user :default "vagrant")
        (database :default "official")
        (server :default "localhost")
        (port :default 15452)))
(setq sql-product 'postgres)



;; scan through tokens with alt n and alt p
(use-package smartscan
    :ensure t)
(smartscan-mode 1)

;; weather check mode
(use-package wttrin
    :ensure t)
(setq wttrin-default-cities '("Plymouth"
                                "Exeter"))

;; stan mode
(use-package stan-mode
    :ensure t)

;; ess
 (use-package ess
  :ensure t
  :init (require 'ess-site))

;; yasnippet
(use-package yasnippet
    :ensure t)
(setq yas-snippet-dirs '("~/configs/emacs/ya_snippets/"))
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)
(add-hook 'splunk-mode-hook 'yas-minor-mode)
(add-hook 'sql-interactive-mode-hook
          #'(lambda () (setq yas--extra-modes '(sql-mode))))
(yas-global-mode 1)

;; org mode
;;(make-frame-command)
;;(split-window-below)
;;(split-window-right)
;;(other-window 2)
;;(split-window-right)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

(setq org-agenda-time-grid (quote
                             ((daily today remove-match)
                              (0900 1100 1300 1500 1700)
                              "......" "----------------")))
(setq org-agenda-files (list "~/configs/admin/planner.org"
                             "~/configs/admin/schedule.org"
<<<<<<< HEAD
                             "~/configs/admin/github_projects.org"
                             "~/configs/admin/asana.org")) 
=======
                             "~/configs/admin/github_projects.org"))
>>>>>>> 0f0234e (old file)
(setq org-export-with-properties '("EFFORT"))

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

<<<<<<< HEAD
=======
(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t))) ; this line activates ditaa
(setq org-ditaa-jar-path "~/configs/admin/ditaa0_9.jar")

(org-babel-do-load-languages
 'org-babel-load-languages
 '((dot . t)))

>>>>>>> 0f0234e (old file)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-agenda-show-all-dates nil)


;; ignore code sections when spellchecking noweave
(add-to-list 'ispell-skip-region-alist '("<<.*>>=" . "^@"))
(defun flyspell-eligible ()
  "Something to do with flyspell."
  (let ((p (point)))
    (save-excursion
      (cond ((re-search-backward (ispell-begin-skip-region-regexp) nil t)
             (ispell-skip-region (match-string-no-properties 0))
             (< (point) p))
            (t)))))
(put 'latex-mode 'flyspell-mode-predicate 'flyspell-eligible)

;; poly-R mode for R nowebs
(use-package poly-R
    :ensure t)

;; (use-package sqlformat
;;    :ensure t)

(use-package leuven-theme
    :ensure t)

(use-package ansible
    :ensure t)

(use-package sed-mode
    :ensure t)

(use-package all-the-icons)

(use-package all-the-icons-dired
  :ensure t)

;;(setq emacsql-sqlite-executable "/usr/share/bash-completion/completions/sqlite3")

(use-package forge
  :after magit)

(use-package toggle-quotes
    :ensure t)

(use-package sqlup-mode
    :ensure t)


(use-package string-inflection
    :ensure t)

(setq latex-run-command "pdflatex")

(defun xml-pretty-print (beg end &optional arg)
"Reformat the region between BEG and END.
With optional ARG, also auto-fill."
  (interactive "*r\nP")
  (let ((fill (or (bound-and-true-p auto-fill-function) -1)))
    (sgml-mode)
    (when arg (auto-fill-mode))
    (sgml-pretty-print beg end)
    (nxml-mode)
    (auto-fill-mode fill)))

;; org-preserve-local-variables error (due to org refile)
;; run this to clear out .elc
;; find org*/*.elc -print0 | xargs -0 rm

;; touch function
(defun touch ()
     "Update timestamp on target buffer."
     (interactive)
     (shell-command (concat "touch " (shell-quote-argument (buffer-file-name))))
     (clear-visited-file-modtime))

(provide '.emacs)
;;; .emacs ends here
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
