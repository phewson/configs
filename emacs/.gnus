;;; package --- Summary
;;; Sets up gnus with a demon to check for new main and provide a desktop notification
;;; Commentary:
;;; Code also added to autoreply to correct email

;;(add-to-list 'load-path "/home/FUTURES.CITY/phewson/.emacs.d/elpa/gnus-desktop-notify-1.4")

;;(require 'gnus-demon)
;;(gnus-demon-add-handler 'gnus-demon-scan-mail 10 t)

(setq gnus-summary-line-format
      (concat "%U%R%z%I%(%&user-date; %[%4L: %-23,23f%]%) %s\n"))

;;(require 'gnus-desktop-notify)
;;(gnus-desktop-notify-mode)
;;(gnus-demon-add-scanmail)
;;;(setq gnus-desktop-notify-groups 'gnus-desktop-notify-explicit)

;;; Code:

;;(setq gnus-parameters
;;      '(("mail\\..*"
;;         (display . all))
;;      ))

;; (setq user-mail-address "paul.hewson@cityscience.com"
;;       user-full-name "Paul Hewson")

;; (setq gnus-select-method
;;       '(nnimap "futures.city"
;;        (nnimap-inbox "Inbox")
;;        (nnimap-address "outlook.office365.com")
;;        (nnimap-server-port 993)
;;        (nnimap-stream ssl)
;;        (nnir-search-engine imap)
;;        (nnimap-authenticator login)))

(setq gnus-select-method
      '(nnimap "gmail"
      (nnimap-address "imap.gmail.com")
      (nnimap-server-port "imaps")
      (nnimap-stream ssl)))

;;(setq smtpmail-smtp-server "smtp.office365.com"
;;      smtpmail-smtp-service 587
;;      )

(setq gnus-posting-styles
 '((".*"
;;  (address "paul.hewson@cityscience.com")
;;  (name "Paul Hewson")
;;  ("X-Message-SMTP-Method" "smtp smtp.office365.com 587 phewson@futures.city"))
;; ("^nnimap[+]gmail:.*"
  (address "texhewson@gmail.com")
  (name "Paul Hewson")
  ("X-Message-SMTP-Method" "smtp smtp.gmail.com 587 texhewson"))))

;;(add-to-list 'gnus-secondary-select-methods '(nnimap "gmail"
;;       (nnimap-address "imap.gmail.com")
;;       (nnimap-server-port "imaps")
;;       (nnimap-stream ssl)))

;; INCOMING EXCHANGE (NNIMAP)
;; assumes davmail running
;;  (add-to-list 'gnus-secondary-select-methods '(nnimap "prcdtr"
;;       (nnimap-inbox "Inbox")
;;       (nnimap-address "outlook.office365.com")
;;       (nnimap-server-port 993)
;;       (nnimap-stream ssl)
;;       (nnir-search-engine imap)
;;       (nnimap-authenticator login)))
;; (add-to-list 'gnus-secondary-select-methods '(nnimap "prcdtrorguk.mail.onmicrosoft.com"
;;        (nnimap-inbox "Inbox")
;;        (nnimap-address "outlook.office365.com")
;;        (nnimap-server-port 993)
;;        (nnimap-stream ssl)
;;        (nnir-search-engine imap)
;;        (nnimap-authenticator login)))


(provide '.gnus)
;;; .gnus ends here
