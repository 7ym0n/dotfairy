;;; init-package.el ---                              -*- lexical-binding: t; -*-

;; Copyright (C) 2020

;; Author: 7ym0n.q6e <bb.qnyd@gmail.com>
;; Keywords:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'init-const)
(require 'init-custom)
(require 'init-funcs)

;; create custom env path
(make-custom-directory)

(setq package-user-dir dotfairy-package-dir)
;; Load `custom-file'
(setq custom-file (expand-file-name "custom.el" dotfairy-private-dir))
(when (and (file-exists-p dotfairy-custom-example-file)
           (not (file-exists-p custom-file)))
  ;; At the first startup copy `custom-file' from the example
  (copy-file dotfairy-custom-example-file custom-file)

  ;; Select the package archives
  (if (or (executable-find "curl") (executable-find "wget"))
      (progn
        ;; Get and select the fastest package archives automatically
        (message "Testing connection... Please wait a moment.")
        (set-package-archives
         (dotfairy-test-package-archives 'no-chart)))
    ;; Select package archives manually
    ;; Use `ido-completing-read' for better experience since
    ;; `ivy-mode' is not available at this moment.
    (set-package-archives
     (intern
      (ido-completing-read
       "Select package archives: "
       (mapcar #'symbol-name
               (mapcar #'car dotfairy-package-archives-alist)))))))

(if (file-readable-p custom-file) (load custom-file))

;; Set ELPA packages
(set-package-archives dotfairy-package-archives nil nil t)

;; Initialize packages
(unless (bound-and-true-p package--initialized) ; To avoid warnings in 27
  (setq package-enable-at-startup nil)          ; To prevent initializing twice
  (package-initialize))

;; Setup `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Should set before loading `use-package'
(eval-and-compile
  (setq use-package-always-ensure t)
  (setq use-package-always-defer t)
  (setq use-package-expand-minimally t)
  (setq use-package-enable-imenu-support t))

(eval-when-compile
  (require 'use-package))

;; Required by `use-package'
(use-package diminish)
(use-package bind-key)

;; Update GPG keyring for GNU ELPA
(use-package gnu-elpa-keyring-update)

;; A modern Packages Menu
(use-package paradox
  :init
  (setq paradox-execute-asynchronously t
        paradox-github-token t
        paradox-display-star-count nil)

  ;; Replace default `list-packages'
  (defun my-paradox-enable (&rest _)
    "Enable paradox, overriding the default package-menu."
    (paradox-enable))
  (advice-add #'list-packages :before #'my-paradox-enable)
  :config
  (when (fboundp 'page-break-lines-mode)
    (add-hook 'paradox-after-execute-functions
              (lambda (&rest _)
                (let ((buf (get-buffer-create "*Paradox Report*"))
                      (inhibit-read-only t))
                  (with-current-buffer buf
                    (page-break-lines-mode 1))))
              t)))

;; Auto update packages
(use-package auto-package-update
  :init
  (setq auto-package-update-delete-old-versions t
        auto-package-update-hide-results t)
  (defalias 'upgrade-packages #'auto-package-update-now))

(provide 'init-package)
;;; init-package.el ends here
