;;; package --- summary
;;; Commentary:
;;; Code:

;; This is meant to be an accessible theme, but, ouch.
(load-theme 'modus-operandi t)

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
  (global-set-key (kbd "C-x l") 'pulsar-pulse-line)  (global-set-key (kbd "C-x C-l") 'pulsar-pulse-buffer))

;; Remember and restore the last cursor location of opened files
(save-place-mode 1)

(setq custom-file (locate-user-emacs-file "~/configs/emacs/.custom-vars.el"))
(load custom-file 'noerror 'nomessage)

;; Don't pop up UI dialogs when prompting
(setq use-dialog-box nil)

;; Revert buffers when the underlying file has changed
(global-auto-revert-mode 1)

;; Revert Dired and other buffers
(setq global-auto-revert-non-file-buffers t)

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
(tool-bar-mode 0)



(setq-default line-spacing 0.4)
;;(setq-default custom-set-faces
;;   '((t (:family "Ubuntu" :foundry "DAMA" :slant normal :weight
;;     normal :height 143 :width normal))))

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
;;(setq column-number-mode t)
;; linum mode
;;(global-linum-mode t)
;;(global-display-line-numbers-mode)
(column-number-mode t)
(global-display-line-numbers-mode t)

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


(setq erc-server "irc.libera.chat"
      erc-nick "texhewson"
      erc-user-full-name "Paul Hewson"
      erc-track-shorten-start 8
      erc-autojoin-channels-alist '(("irc.libera.chat" "#systemcrafters" "#emacs"))
      erc-kill-buffer-on-part t
            erc-auto-query 'bury)

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
;;(require 'ox-reveal)

(use-package docker
  :ensure t)

(use-package docker-compose-mode
  :ensure t)

;; json mode
(use-package json-mode
  :ensure t)

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

;;THis never seemed to work?
;;(use-package dired-single
;;  :ensure t)
(setf dired-kill-when-opening-new-dired-buffer t)

(setq dired-listing-switches "-lah --group-directories-first")
(when (display-graphic-p)
  (require 'all-the-icons))
(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode)
  :config (setq all-the-icons-dired-monochrome nil)
  )
;; M-x all-the-icons-install-fonts

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

;; (use-package powerline
;;   :ensure t)
;; (defun my-powerline-setup ()
;;   (interactive)
;;   (setq-default mode-line-format
;;                 '("%e"
;;                   (:eval
;;                    (let* ((active (powerline-selected-window-active))
;;                           (mode-line (if active 'mode-line 'mode-line-inactive))
;;                           (face1 (if active 'powerline-active1 'powerline-inactive1))
;;                           (face2 (if active 'powerline-active2 'powerline-inactive2))
;;                           (separator-left (intern (format "powerline-%s-%s"
;;                                                           powerline-default-separator
;;                                                           (car powerline-default-separator-dir))))
;;                           (separator-right (intern (format "powerline-%s-%s"
;;                                                            powerline-default-separator
;;                                                            (cdr powerline-default-separator-dir))))
;;                           (lhs (list (powerline-raw "%*" nil 'l)
;;                                      (powerline-buffer-id nil 'l)
;;                                      (powerline-raw " ")
;;                                      (funcall separator-left mode-line face1)
;;                                      (powerline-narrow face1 'l)
;;                                      (powerline-vc face1)))
;;                           (rhs (list (powerline-raw global-mode-string face1 'r)
;;                                      (funcall separator-right face1 face2)
;;                                      (powerline-raw "%4l" face2 'r)
;;                                      (powerline-raw ":" face2 'r)
;;                                      (powerline-raw "%3c" face2 'r)
;;                                      (funcall separator-right face2 mode-line)
;;                                      (powerline-raw " ")
;;                                      (powerline-raw "%6p" nil 'r)
;;                                      (powerline-hud face2 face1)))
;;                           (center (list (powerline-raw " " face1)
;;                                         (powerline-raw (all-the-icons-icon-for-buffer) face1 'l)
;;                                         (powerline-major-mode face1 'l)
;;                                         (powerline-process face1)
;;                                         (powerline-minor-modes face1 'l)
;;                                         (powerline-raw " " face1))))
;;                      (concat (powerline-render lhs)
;;                              (powerline-fill-center face1 (/ (powerline-width center) 2.0))
;;                              (powerline-render center)
;;                              (powerline-fill face1 (powerline-width rhs))
;;                              (powerline-render rhs)))))))

;; ;; Apply custom powerline setup
;; (my-powerline-setup)

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

;;(require 'dired-x)
;;(setq-default dired-omit-files-p t)
;;(setq dired-omit-files
;;      (concat dired-omit-files "\\.doc$"))

(use-package hackernews
  :ensure t)

(use-package elfeed
  :ensure t)
(setq elfeed-feeds '("https://martinfowler.com/feed.atom"
		     "https://opensource.com/feed"
		     "https://feeds.feedburner.com/RBloggers"
		     "https://planet.debian.org/rss20.xml"
		     "https://sachachua.com/blog/feed/index.xml"
		     "https://karthinks.com/tags/elfeed/index.xml"
		     "https://ctan.org/ctan-ann/rss"))

;; stan mode
(use-package stan-mode
    :ensure t)

;; ess
 (use-package ess
  :ensure t
  :init (require 'ess-site))

(use-package poly-R
  :ensure t
)

(use-package auctex
  :ensure t)
(setq auto-mode-alist (append '(("\\.tex\\'" . LaTeX-mode)) auto-mode-alist))

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

(use-package cdlatex
  :ensure t)

(use-package consult
  :ensure t)

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Documents")
    (setq projectile-project-search-path '("~/Documents")))
  (setq projectile-switch-project-action #'projectile-dired))

;;(use-package counsel-projectile
;; :after projectile
;; :config
;; (counsel-projectile-mode 1))


;; Enable tab-bar-mode
;;(tab-bar-mode 1)

;;(use-package tabspaces
;;  :ensure t
;;  :hook (after-init . tabspaces-mode)
;;  :commands (tabspaces-switch-or-create-workspace
;;             tabspaces-open-or-create-project-and-workspace)
;;  :custom
;;  (tabspaces-use-filtered-buffers-as-default t)
;;  (tabspaces-default-tab "Default")
;;  (tabspaces-remove-to-default t)
;;  (tabspaces-include-buffers '("*scratch*"))
;;  (tabspaces-initialize-project-with-todo t)
;;  (tabspaces-todo-file-name "project-todo.org")
;;  (tabspaces-session t)
;;  (tabspaces-session-auto-restore t))
;;
;;(global-set-key (kbd "C-c t s") 'tabspaces-switch-or-create-workspace)
;;(global-set-key (kbd "C-c t o") 'tabspaces-open-or-create-project-and-workspace)
;;(global-set-key (kbd "C-c t r") 'tabspaces-remove-current-buffer)

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


;;(add-to-list 'load-path "~/Downloads")
;;; wget https://github.com/latex-lsp/texlab/releases/download/v5.16.1/texlab-x86_64-linux.tar.gz in Downloads (need to change the location)
;; tar -xvf texlab-x86_64-linux.tar.gz 

(require 'eglot)
(add-to-list 'eglot-server-programs '(latex-mode . ("~/Downloads/texlab")))
(add-hook 'latex-mode-hook 'eglot-ensure)
(use-package company
  :ensure t
  :hook (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 1
        company-selection-wrap-around t
        company-frontends '(company-pseudo-tooltip-frontend
                            company-echo-metadata-frontend)))

(use-package company-auctex
  :ensure t
  :config
  (company-auctex-init))

(eval-after-load "tex" 
  '(setcdr (assoc "LaTeX" TeX-command-list)
          '("%`%l%(mode) -shell-escape%' %t"
          TeX-run-TeX nil (latex-mode doctex-mode) :help "Run LaTeX")
    )
  )
(use-package xenops
  :ensure t)

(require 'ob-python)

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))


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



(load-file "~/configs/emacs/.orgconfigs.el")

;;(use-package counsel
;;     :ensure t)

;;(use-package all-the-icons-ivy-rich
;;  :ensure t
;;  :init (all-the-icons-ivy-rich-mode 1))
;;(setq all-the-icons-ivy-rich-icon t)

;;(use-package ivy-rich
;;  :init (ivy-rich-mode 1)
;;)

;;(ivy-mode 1)
;;(counsel-mode 1)

(use-package academic-phrases
  :ensure t)

(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode)
  )

;; I think this is useless
;; requires manual source from emacs wiki
;;(add-to-list 'load-path "~/.emacs.d/elpa/hl-line+")
;;(require 'hl-line+)

;; Enable command logging
;;(setq message-log-max t)

;; Function to print a message to *Messages*
;;(defun my-echo-command (command)
;;  (message "Command executed: %s" command))

;; Hook into the post-command-hook to log every command
;;(add-hook 'post-command-hook
;;          (lambda ()
;;            (my-echo-command this-command)))


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
;;https://lucidmanager.org/productivity/emacs-bibtex-mode/
;;https://github.com/pprevos/emacs-writing-studio
(provide '.emacs)
;;; .emacs ends here
 ;; If there is more than one, they won't work right.

;; (update emacs)
