;;; init.el --- cleaned config -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;; ------------------------------------------------------------
;; Disable package.el — straight.el replaces it
;; ------------------------------------------------------------
(setq package-enable-at-startup nil)
;;(setq straight-built-in-pseudo-packages '(auth-source-xoauth2))

;; ------------------------------------------------------------
;; Bootstrap straight.el
;; ------------------------------------------------------------
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el"
                         user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(straight-use-package 'org)
(eval-when-compile
  (require 'use-package))

;; ------------------------------------------------------------
;; Core UI & defaults
;; ------------------------------------------------------------

(load-theme 'modus-operandi t)
(set-frame-font "DejaVu Sans Mono-11" nil t)

(setq inhibit-splash-screen t
      use-dialog-box nil
      initial-buffer-choice "~/configs/admin/tasks.org")

(add-to-list 'default-frame-alist '(width . 101))

(tool-bar-mode -1)

(column-number-mode t)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

(setq-default line-spacing 0.4)
(setq require-final-newline t)

(prefer-coding-system 'utf-8-unix)

(save-place-mode 1)
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key (kbd "C-x C-r") #'recentf-open-files)

;; ------------------------------------------------------------
;; Completion (modern minimal stack)
;; ------------------------------------------------------------

(use-package vertico
  :init (vertico-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

(use-package marginalia
  :init (marginalia-mode))

(use-package consult)

;; optional but recommended
(use-package corfu
  :init (global-corfu-mode))

;; ------------------------------------------------------------
;; Environment (Emacs-specific)
;; ------------------------------------------------------------

(setenv "DATASTORE" "/home/phewson/DATA")
(setenv "PGUSER" "pgdocker")
(setenv "PGHOST" "localhost")
(setenv "PGDATABASE" "official")
(setenv "PGPORT" "15432")

(use-package direnv
  :config (direnv-mode))

;; ------------------------------------------------------------
;; Navigation & editing
;; ------------------------------------------------------------

(windmove-default-keybindings)

(use-package pulsar
  :config
  (pulsar-global-mode 1))


(use-package writeroom-mode
  :custom (writeroom-width 100)
  :hook (writeroom-mode . (lambda ()
                            (display-line-numbers-mode
                             (if writeroom-mode -1 1)))))
(global-set-key (kbd "<f9>") #'writeroom-mode)

(setq dired-kill-when-opening-new-dired-buffer t)
(setq dired-listing-switches "-lah --group-directories-first")

;; ------------------------------------------------------------
;; Eglot (LSP)
;; ------------------------------------------------------------

(use-package eglot
  :hook ((ess-r-mode . eglot-ensure)
         (python-mode . eglot-ensure)
         (c++-ts-mode . eglot-ensure)
         (LaTeX-mode . eglot-ensure)))

;; ------------------------------------------------------------
;; R / ESS
;; ------------------------------------------------------------

(use-package ess
  :init (require 'ess-site)
  :config
  (setq ess-indent-offset 2))

;; ------------------------------------------------------------
;; SQL
;; ------------------------------------------------------------

(setq sql-product 'postgres)
(setq sql-postgres-login-params
      '((user :default "pgdocker")
        (database :default "official")
        (server :default "localhost")
        (port :default 15432)))

;; ------------------------------------------------------------
;; LaTeX
;; ------------------------------------------------------------

(use-package auctex
  :hook (LaTeX-mode . (lambda ()
                        (turn-on-reftex)
                        (flyspell-mode)
                        (TeX-fold-mode)))
  :config
  (setq TeX-auto-save t
        TeX-parse-self t
        TeX-source-correlate-mode t
        TeX-view-program-selection '((output-pdf "PDF Tools"))))

(use-package cdlatex)
(use-package xenops)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(LaTeX-mode . ("texlab"))))

;; ------------------------------------------------------------
;; Programming tools
;; ------------------------------------------------------------

(setq major-mode-remap-alist
      '((c++-mode . c++-ts-mode)
        (python-mode . python-ts-mode)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package flycheck
  :init (global-flycheck-mode))

(add-hook 'text-mode-hook #'flyspell-mode)

;; ------------------------------------------------------------
;; Utilities
;; ------------------------------------------------------------

(use-package magit)
(use-package docker)
(use-package docker-compose-mode)
(use-package json-mode)
(use-package stan-mode)

(use-package wgrep)
(use-package vundo
  :bind (("C-x u" . vundo)))

(use-package browse-kill-ring
  :bind (("M-y" . browse-kill-ring)))

;; ------------------------------------------------------------
;; Feeds
;; ------------------------------------------------------------

(use-package elfeed)
(setq elfeed-feeds
      '(("https://martinfowler.com/feed.atom")
        ("https://feeds.feedburner.com/RBloggers")
        ("https://planet.debian.org/rss20.xml")
        ("https://ctan.org/ctan-ann/rss")))

;; 1. Load mu4e from your specific path
(add-to-list 'load-path "/usr/share/emacs/site-lisp/elpa-src/mu4e-1.8.14")
(require 'mu4e)
(setq user-mail-address "texhewson@gmail.com"
      user-full-name    "Paul Hewson")
;; 2. Simplified OAuth2 (Using the built-in Emacs 29+ or ELPA version)
(use-package auth-source-xoauth2
  :straight t
  :config
  (auth-source-xoauth2-enable))

;; 3. mu4e Basic Settings
(setq mu4e-maildir "~/Mail/gmail"
      mu4e-get-mail-command "/usr/bin/mbsync -a"
      mu4e-sent-folder   "/[Gmail]/Enviados"
      mu4e-drafts-folder "/[Gmail]/Borradores"
      mu4e-trash-folder  "/[Gmail]/Papelera"
      ;;mu4e-refile-folder "/[Gmail]/Todos"
      )

(setq mu4e-index-update-error nil)
(setq mu4e-get-mail-command "/usr/bin/mbsync -a"
      mu4e-update-interval nil) ;; Disables the timer so 'g' is the manual trigger

;;(with-eval-after-load 'mu4e
;;  ;; Bind 'g' in the headers view
;;  (define-key mu4e-headers-mode-map (kbd "g") 'mu4e-update-mail-and-index)
;;  ;; Bind 'g' in the main mu4e dashboard/menu
;;  (define-key mu4e-main-mode-map (kbd "g") 'mu4e-update-mail-and-index))

;; Recommended: Update your shortcuts for these specific paths
(setq mu4e-maildir-shortcuts
    '( ("/INBOX"            . ?i)
       ("/[Gmail]/Enviados" . ?s)
       ("/[Gmail]/Papelera" . ?t)
       ;; ("/[Gmail]/Todos"    . ?a)
       ("/Work"             . ?w)))

(setq mu4e-change-filenames-when-moving t)

;; 4. Sending Mail via msmtp
(setq message-send-mail-function 'message-send-mail-with-sendmail
      sendmail-program "msmtp"
      message-sendmail-f-is-evil t
      message-sendmail-extra-arguments '("--read-envelope-from"))

;; 3. Fixed Face Attributes (The inheritance fix)
(with-eval-after-load 'mu4e
  (set-face-attribute 'mu4e-header-key-face nil :inherit 'font-lock-keyword-face)
  (set-face-attribute 'mu4e-header-value-face nil :inherit 'font-lock-variable-name-face :bold nil)
  (setq mu4e-view-show-addresses t
        mu4e-view-hide-cited t))

;; 1. Your Custom Naming Logic (Unchanged)
(defun my-sc-author-name (full)
  "Return 'First S' and handle email brackets correctly."
  (let* ((clean-full (replace-regexp-in-string "<.*>" "" (or full ""))) ;; Strip <email>
         (parts (split-string (string-trim clean-full)))
         (first (car parts))
         (last (car (last parts))))
    (if (and first last (not (string= first last)))
        (concat first " " (substring last 0 1))
      (or first "Someone"))))

;; 2. The Custom Attributed Citation Engine
(setq mu4e-compose-cite-function
      (lambda ()
        (let* ((from (message-fetch-field "from"))
               (date (message-fetch-field "date"))
               (author (my-sc-author-name from))
               ;; Use a space after the > for readability
               (citation-prefix (concat author "> ")))
          
          ;; Insert Header
          (goto-char (point))
          (insert (format  "%s interacted with some tech device on %s causing millions of electrons to dance ultimately resulting in these characters wandering round cyberspace:\n\n"
                          author (or date "a certain day")))
          
          ;; The "Nested" Magic: 
          ;; We bind 'message-yank-prefix' to our new author,
          ;; and Emacs will naturally put it in front of existing '>' marks.
          (let ((message-yank-prefix citation-prefix)
                (message-indentation-spaces 0))
            (message-cite-original-without-signature)))))

;; ------------------------------------------------------------
;; Snippets
;; ------------------------------------------------------------


(use-package yasnippet
  :config
  (setq yas-snippet-dirs '("~/configs/emacs/ya_snippets/"))
  (yas-global-mode 1))

;; ------------------------------------------------------------
;; LanguageTool
;; ------------------------------------------------------------

(use-package languagetool
  :config
  (setq languagetool-java-bin "/usr/bin/java"))

;;-------------------------------------------------------------
;; Icons
;; M-x all-the-icons-install-fonts
;;-------------------------------------------------------------

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :init (all-the-icons-completion-mode)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup))

(use-package nerd-icons-dired
  :hook (dired-mode . nerd-icons-dired-mode))


;; ------------------------------------------------------------
;; Custom file
;; ------------------------------------------------------------

(setq custom-file (locate-user-emacs-file ".custom-vars.el"))
(load custom-file 'noerror 'nomessage)

;; ------------------------------------------------------------
;; Org (separate config)
;; ------------------------------------------------------------

(load-file "~/configs/emacs/.orgconfigs.el")

(provide 'init)
;;; init.el ends here
