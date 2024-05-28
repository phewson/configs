;;; package --- summary
;;; Commentary:
;;; Code:

;; set various environmental variables
;;(setenv "TEST_DATA_HOME" "/home/phewson/analytics-queries/ci/tests/sim_data")
;;(setenv "HOME" "~/")
(setenv "PGUSER" "vagrant")
(setenv "PGHOST" "localhost")
(setenv "PGDATABASE" "official")
(setenv "PGPORT" "15432")
(setq sql-postgres-login-params
      '((user :default "vagrant")
        (database :default "official")
        (server :default "localhost")
        (port :default 15452)))
(setq sql-product 'postgres)

;; open with an org mode file as default
(setq inhibit-splash-screen t
      initial-buffer-choice "~/configs/admin/planner.org")
;;(find-file "~/configs/admin/planner.org")

;; turn on visual icon toolbar
(tool-bar-mode 1)

(setq-default line-spacing 0.4)
(setq-default custom-set-faces
   '((t (:family "Ubuntu" :foundry "DAMA" :slant normal :weight
     normal :height 143 :width normal))))

;; default to pdflatex
(setq latex-run-command "pdflatex")

;; use utf-8
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; allow opening of recent files via menu or Ctrl-x Ctrl-r
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

;; include column numbers for cursor in modeline
(setq column-number-mode t)

;; stop shell duplicating history
(defvar comint-input-ignoredups)
(setq comint-input-ignoredups t)

;; idf files handled by config mode
;;(add-to-list 'auto-mode-alist '("\\.idf\\'" . conf-mode))

;; needed for some applications
(setq require-final-newline t)

;; set transparency
;;(set-frame-parameter (selected-frame) 'alpha '(85 85))
;;(add-to-list 'default-frame-alist '(alpha 85 85))

;; tree sitter mode source grammars
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

;; make c++ mode tree sitter mode
(setq major-mode-remap-alist
 '((c++-mode . c++-ts-mode)
   )
 )

;; I forgot why I wrote this, turns a column of data into a comma separated
;;list for use in R?
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


;; touch function
(defun touch ()
     "Update timestamp on target buffer."
     (interactive)
     (shell-command (concat "touch " (shell-quote-argument (buffer-file-name))))
     (clear-visited-file-modtime))

(setq abbrev-file-name             ;; tell emacs where to read abbrev
       "~/configs/emacs/abbrev/.abbrev_defs")
(setq save-abbrevs 'silent)

;; I don't think I work with XML anymore
;;(add-hook 'nxml-mode-hook 'abbrev-mode)

;;(require 'emamux)
;;(add-hook 'nxml-mode-hook
;;          (lambda () (add-to-list
;;                      'write-file-functions 'delete-trailing-whitespace)))

;; needed for python/conda
;;(add-to-list 'exec-path "~/miniconda/bin")
;; needed for windows
;;(add-to-list 'exec-path "/c/mingw/bin")

;; where to find elisp pacakges
(add-to-list 'load-path (expand-file-name "~/configs/misc_el/"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/elpa/"))

(require 'package)
(setq package-archives
   (quote
    (("melpa" . "https://melpa.org/packages/")
     ("gnu" . "https://elpa.gnu.org/packages/"))))

(package-initialize)


(eval-when-compile
;;  ;; Following line is not needed if use-package.el is in ~/.emacs.d
(require 'use-package))
(require 'bind-key)
(setq use-package-always-ensure t)
;; (add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/"))

(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe))

(use-package magit
  :ensure t)

;;(add-to-list 'load-path "~/.emacs.d/elpa/emacs-reveal")
;;(require 'emacs-reveal)
;;(require 'org-re-reveal)
(require 'ox-reveal)

(use-package camcorder
  :ensure t)

(use-package docker
  :ensure t)

(use-package docker-compose-mode
  :ensure t)

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

(use-package hackernews
  :ensure t)

(use-package elfeed
  :ensure t)
(setq elfeed-feeds '("https://martinfowler.com/feed.atom"
		     "https://opensource.com/feed"
		     "https://feeds.feedburner.com/RBloggers"))

;; stan mode
(use-package stan-mode
    :ensure t)

;; ess
 (use-package ess
  :ensure t
  :init (require 'ess-site))

(use-package auctex
  :ensure t)
(setq auto-mode-alist (append '(("\\.tex\\'" . LaTeX-mode)) auto-mode-alist))


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

;; flycheck
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

(use-package quelpa
  :ensure t)

(quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://github.com/quelpa/quelpa-use-package.git"))
(require 'quelpa-use-package)

;; grammar and translation software
(use-package reverso
  :quelpa ((reverso :fetcher github :repo  "SqrtMinusOne/reverso.el")
           :upgrade t)
  )

(load-file "~/configs/emacs/.orgconfigs.el")

(use-package biblio
  :ensure t)
;;https://lucidmanager.org/productivity/emacs-bibtex-mode/
;;https://github.com/pprevos/emacs-writing-studio
(provide '.emacs)
;;; .emacs ends here

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ox-reveal org-ref oer-reveal camcorder gif-screencast org-roam biblio yasnippet wttrin wgrep toggle-quotes string-inflection stan-mode sqlup-mode smartscan sed-mode reverso quelpa-use-package poly-R pkg-info ov org-journal leuven-theme json-mode jinja2-mode helm hackernews forge flycheck ess elfeed docker-compose-mode docker auto-package-update auctex ansible all-the-icons-dired)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
