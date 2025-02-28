;;; package --- summary
;;; Commentary:
;;; Code:

(load-theme 'modus-operandi t)
(set-frame-font "DejaVu Sans Mono-11" nil t)

(setq use-dialog-box nil)

(setq inhibit-splash-screen t
        initial-buffer-choice "~/configs/admin/planner.org")
(add-to-list 'initial-frame-alist '(width . 101))
(add-to-list 'default-frame-alist '(width . 101))

(tool-bar-mode 0)

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

(column-number-mode t)
(global-display-line-numbers-mode t)

(setq-default line-spacing 0.4)

(use-package writeroom-mode
  :ensure t
  :hook
  (writeroom-mode . (lambda ()
                      (if writeroom-mode
                          (progn
                            (setq original-frame-width (frame-width))
                            (setq original-frame-height (frame-height))
                            (display-line-numbers-mode -1))
                        (progn
                          (display-line-numbers-mode 1)
                          (set-frame-width (selected-frame) original-frame-width)
                          (set-frame-height (selected-frame) original-frame-height)))))
)
(global-set-key (kbd "<f9>") 'writeroom-mode)

(setf dired-kill-when-opening-new-dired-buffer t)
(setq dired-listing-switches "-lah --group-directories-first")

(use-package pulsar
    :ensure t
    :config
    ;; Enable pulsar-mode globally
    (pulsar-global-mode 1)

    ;; Optionally, customize pulsar's behavior
    (setq pulsar-pulse t)
    (setq pulsar-delay 0.05)
    (setq pulsar-iterations 10)
    (setq pulsar-face 'pulsar-magenta)
    (setq pulsar-highlight-face 'pulsar-yellow)

    ;; Optionally, set up key bindings for pulsar commands
    (global-set-key (kbd "C-x l") 'pulsar-pulse-line)
)

(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

(setq require-final-newline t)

(setq ess-style 'RRR)

(require 'eglot)

(setq erc-server "irc.libera.chat"
      erc-nick "texhewson"
      erc-user-full-name "Paul Hewson"
      erc-track-shorten-start 8
      erc-autojoin-channels-alist '(("irc.libera.chat" "#systemcrafters" "#emacs"))
      erc-kill-buffer-on-part t
            erc-auto-query 'bury)

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

;; make c++ mode tree sitter mode
(setq major-mode-remap-alist '((c++-mode . c++-ts-mode)))

(save-place-mode 1)

(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)

(setq custom-file (locate-user-emacs-file "~/configs/emacs/.custom-vars.el"))
(load custom-file 'noerror 'nomessage)

;;(setenv "TEST_DATA_HOME" "/home/phewson/analytics-queries/ci/tests/sim_data")
;;(setenv "HOME" "~/")
(setenv "DATASTORE" "/home/phewson/DATA")
(setenv "PGUSER" "pgdocker")
(setenv "PGHOST" "localhost")
(setenv "PGDATABASE" "official")
(setenv "PGPORT" "15432")
(setq sql-postgres-login-params
      '((user :default "pgdocker")
        (database :default "official")
        (server :default "localhost")
        (port :default 15452)))
(setq sql-product 'postgres)

(use-package framemove
    :load-path "~/configs/misc_el/")
(windmove-default-keybindings)
(setq framemove-hook-into-windmove t)
;; (when (fboundp 'windmove-default-keybindings)
;;  (windmove-default-keybindings))

(defvar comint-input-ignoredups)
(setq comint-input-ignoredups t)

(add-to-list 'load-path (expand-file-name "~/configs/misc_el/"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elpa/"))

(require 'package)
(setq package-archives
   (quote
    (("melpa" . "https://melpa.org/packages/")
     ("gnu" . "https://elpa.gnu.org/packages/"))))
(setq package-archive-priorities '(("melpa" . 1)
                                   ("gnu" . 2)))
(package-initialize)
(eval-when-compile

(require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)
(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package ess
  :ensure t
  :init (require 'ess-site))
(add-hook 'ess-r-mode-hook
	  (lambda ()
	    (setq-local eglot-ignored-server-capabilities
			('documentFormattingProvider
			 :documentRangeFormattingProvider))))
(add-hook 'ess-r-mode-hook
	  (lambda () (remove-hook 'before-save-hook 'eglot-format-buffer t)))
(setq ess-indent-offset 2)

(use-package wgrep
  :ensure t)
(use-package magit
  :ensure t)
(use-package docker
  :ensure t)
(use-package docker-compose-mode
  :ensure t)
(use-package json-mode
  :ensure t)
(use-package hackernews
  :ensure t)
(use-package stan-mode
  :ensure t)
(use-package poly-R
  :ensure t)
(use-package academic-phrases
  :ensure t)
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
)
(use-package consult
  :ensure t)

(use-package elfeed
  :ensure t)
(setq elfeed-feeds '(("https://www.joanwestenberg.com/feed"
		 "https://martinfowler.com/feed.atom"
		 "https://uk.fedimeteo.com/plymouth.rss"
		     "https://opensource.com/feed"
		     "https://feeds.feedburner.com/RBloggers"
		     "https://planet.debian.org/rss20.xml"
		     "https://sachachua.com/blog/feed/index.xml"
		     "https://karthinks.com/tags/elfeed/index.xml"
		     "https://ctan.org/ctan-ann/rss"))
    )

(use-package vertico
  :init
  (vertico-mode))

(use-package general
  :ensure t)

(use-package marginalia
  :general
  (:keymaps 'minibuffer-local-map
   "M-A" 'marginalia-cycle)
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init
  (marginalia-mode))

(use-package all-the-icons-completion
  :ensure t
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

(use-package whitespace
  :ensure t)
(setq-default whitespace-line-column 101)
(add-hook 'emacs-lisp-mode-hook
          (function (lambda()
                      (whitespace-mode t))))
(add-hook 'python-mode-hook
          (function (lambda()
                      (whitespace-mode t))))
(add-hook 'r-mode-hook
          (function (lambda()
                      (whitespace-mode t))))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(when (display-graphic-p)
  (require 'all-the-icons))
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode)
  :config (setq all-the-icons-dired-monochrome nil)
  )

(use-package browse-kill-ring
  :ensure t
  :bind (("M-y" . browse-kill-ring))
  :config
  (setq browse-kill-ring-highlight-current-entry t)
  (setq browse-kill-ring-separator "\n--------------------\n")
)

(use-package vundo
  :ensure t
  :bind (("C-x u" . vundo))
  :config
  (setq vundo-compact-display t)
  (setq vundo-roll-back-on-quit t)
)

(setq latex-run-command "pdflatex")

(use-package auctex
  :ensure t)
(setq auto-mode-alist
  (append '(("\\.tex\\'" . LaTeX-mode)) auto-mode-alist))
;; Custom function to split window vertically and display PDF
(defun my-TeX-revert-document-buffer (file)
  "Revert the buffer corresponding to FILE in another window."
  (let ((buf (find-buffer-visiting file)))
    (if buf
        (progn
          (select-window (split-window-right))
          (switch-to-buffer buf)
          (pdf-view-mode)
          (pdf-view-fit-page-to-window))
      (message "No buffer associated with %s" file))))

(setq TeX-view-program-selection '((output-pdf "PDF Tools"))
    TeX-source-correlate-start-server t)

(add-hook 'TeX-after-compilation-finished-functions
        #'TeX-revert-document-buffer)
(use-package cdlatex
    :ensure t)
(use-package xenops
  :ensure t)
    ;;(setq TeX-view-program-list
    ;;      '(("Okular" "okular %o")
    ;;       ("Firefox" "firefox %o")
    ;;       ("Zathura" "zathura %o"))
    ;;)

    ;;(setq TeX-view-program-selection
    ;;      '((output-pdf "Okular")))

    ;; Custom function to split window vertically and display PDF
    (defun my-TeX-revert-document-buffer (file)
      "Revert the buffer corresponding to FILE in another window."
      (let ((buf (find-buffer-visiting file)))
        (if buf
            (progn
              (select-window (split-window-right))
              (switch-to-buffer buf)
              (pdf-view-mode)
              (pdf-view-fit-page-to-window))
          (message "No buffer associated with %s" file))))

    (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
          TeX-source-correlate-start-server t)

    (add-hook 'TeX-after-compilation-finished-functions
              #'TeX-revert-document-buffer)

;;; wget https://github.com/latex-lsp/texlab/releases/download/v5.16.1/texlab-x86_64-linux.tar.gz in Downloads (need to change the location)
      ;; tar -xvf texlab-x86_64-linux.tar.gz 
    (use-package company
      :ensure t
      :config
      (global-company-mode)
      (setq company-backends '(company-capf))
      (setq company-idle-delay 0.2
          company-minimum-prefix-length 1
          company-selection-wrap-around t
          company-frontends '(company-pseudo-tooltip-frontend
                              company-echo-metadata-frontend))
      )  ; Use only company-capf for completions

    ;; Install and configure eglot
    (use-package eglot
      :ensure t
      :hook ((latex-mode . eglot-ensure)
             (LaTeX-mode . eglot-ensure))  ; Ensure eglot starts for LaTeX modes
      :config
      (add-to-list 'eglot-server-programs '(latex-mode . ("~/Downloads/texlab"))))

    ;; Optional: Additional settings for LaTeX editing (e.g., AUCTeX)
    (use-package auctex
      :ensure t
      :defer t
      :hook (LaTeX-mode . (lambda ()
                            (turn-on-reftex)
                            (flyspell-mode)
                            (TeX-fold-mode))))

      (use-package company-auctex
        :ensure t
        :config
        (company-auctex-init))
;; this is for minted I think
      (eval-after-load "tex" 
        '(setcdr (assoc "LaTeX" TeX-command-list)
                '("%`%l%(mode) -shell-escape%' %t"
                TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX")
          )
        )

(use-package yasnippet
    :ensure t)
(setq yas-snippet-dirs '("~/configs/emacs/ya_snippets/"))
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)
(add-hook 'sql-interactive-mode-hook
          #'(lambda () (setq yas--extra-modes '(sql-mode))))
(yas-global-mode 1)

;;(setq flycheck-flake8rc "~/configs/splunk/.flake8")
(use-package flycheck
     :ensure t)
;;(use-package flycheck-mypy
;;     :load-path "~/configs/misc_el")
(global-flycheck-mode)
(add-hook 'after-init-hook #'global-flycheck-mode)
(add-hook 'c++-mode-hook
    (lambda() (setq flycheck-gcc-include-path
       (list (expand-file-name "~/R/x86_64-pc-linux-gnu-library/4.0/testthat/include")
             (expand-file-name "~/R/x86_64-pc-linux-gnu-library/4.0/Rcpp/include"))
)))
(setq flycheck-checker-error-threshold 800)
(setq flycheck-lintr-linters "with_defaults(line_length_linter(100))")
(setq flycheck-python-flake8-executable "~/miniconda3/envs/splunk/bin/flake8")
(setq flycheck-python-mypy-executable "~/miniconda3/envs/splunk/bin/mypy")
(setq magit-log-arguments '("--graph" "--color" "--decorate" "-n256"))

(dolist (hook '(text-mode-hook))
  (add-hook hook (lambda () (flyspell-mode 1))))

;; stack exchange hack, ubuntu has old version of shell linter
(setq flycheck-shellcheck-follow-sources nil)
(add-hook 'sh-mode-hook 'flycheck-mode)

(use-package languagetool
  :ensure t
  :defer t
  :commands (languagetool-check
             languagetool-clear-suggestions
             languagetool-correct-at-point
             languagetool-correct-buffer
             languagetool-set-language
             languagetool-server-mode
             languagetool-server-start
             languagetool-server-stop)
     :config
  (setq languagetool-java-bin "/usr/bin/java"
        languagetool-server-command "/snap/languagetool/current/usr/bin/languagetool-server.jar"
       languagetool-console-command "/snap/languagetool/current/usr/bin/languagetool-commandline.jar"
        languagetool-java-arguments '("-Dfile.encoding=UTF-8")
	)
)

(use-package citar
:custom
  (citar-bibliography '("~/configs/admin/papers/regression.bib"))
  :hook (org-mode . citar-capf-setup)
)

(use-package citar-org-roam
  :after (citar org-roam)
  :config (citar-org-roam-mode))

;;(use-package biblio
;;  :ensure t)

(load-file "~/configs/emacs/.orgconfigs.el")

(provide '.emacs)
;;; .emacs ends here
