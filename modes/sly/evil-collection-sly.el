;;; evil-collection-sly.el --- Evil bindings for `sly' -*- lexical-binding: t -*-

;; Copyright (C) 2019 Pierre Neidhardt

;; Author: James Nguyen <james@jojojames.com>
;; Maintainer: James Nguyen <james@jojojames.com>
;; Pierre Neidhardt <mail@ambrevar.xyz>
;; URL: https://github.com/emacs-evil/evil-collection
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1"))
;; Keywords: evil, sly, tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Evil bindings for `sly-mode'.

;;; Code:
;; WARNING: This mirrors evil-collection-slime.el.  Keep them in sync!

(require 'evil-collection)
(require 'sly nil t)

(defvar sly-db-mode-map)
(defvar sly-inspector-mode-map)
(defvar sly-mode-map)
(defvar sly-popup-buffer-mode-map)
(defvar sly-thread-control-mode-map)
(defvar sly-xref-mode-map)

(defconst evil-collection-sly-maps '(sly-db-mode-map
                                     sly-inspector-mode-map
                                     sly-mode-map
                                     sly-popup-buffer-mode-map
                                     sly-thread-control-mode-map
                                     sly-xref-mode-map))

;; Same as `evil-collection-slime-last-sexp'.
(defun evil-collection-sly-last-sexp (command &rest args)
  "In normal-state or motion-state, last sexp ends at point."
  (if (and (not evil-move-beyond-eol)
           (or (evil-normal-state-p) (evil-motion-state-p)))
      (save-excursion
        (unless (or (eobp) (eolp)) (forward-char))
        (apply command args))
    (apply command args)))

;;;###autoload
(defun evil-collection-sly-setup ()
  "Set up `evil' bindings for `sly'."
  (unless evil-move-beyond-eol
    (advice-add 'sly-eval-last-expression :around 'evil-collection-sly-last-sexp)
    (advice-add 'sly-pprint-eval-last-expression :around 'evil-collection-sly-last-sexp)
    (advice-add 'sly-eval-print-last-expression :around 'evil-collection-sly-last-sexp)
    (advice-add 'sly-mrepl-return :around 'evil-collection-sly-last-sexp))

  (evil-collection-define-key 'normal 'sly-db-mode-map
    [follow-link] 'mouse-face
    "\C-i" 'sly-db-cycle
    "g?" 'describe-mode
    "S" 'sly-db-show-frame-source
    "e" 'sly-db-eval-in-frame
    "d" 'sly-db-pprint-eval-in-frame
    "D" 'sly-db-disassemble
    "i" 'sly-db-inspect-in-frame
    "gj" 'sly-db-down
    "gk" 'sly-db-up
    (kbd "C-j") 'sly-db-down
    (kbd "C-k") 'sly-db-up
    "]]" 'sly-db-details-down
    "[[" 'sly-db-details-up
    (kbd "M-j") 'sly-db-details-down
    (kbd "M-k") 'sly-db-details-up
    "gg" 'sly-db-beginning-of-backtrace
    "G" 'sly-db-end-of-backtrace
    "t" 'sly-db-toggle-details
    "gr" 'sly-db-restart-frame
    "I" 'sly-db-invoke-restart-by-name
    "R" 'sly-db-return-from-frame
    "c" 'sly-db-continue
    "s" 'sly-db-step
    "n" 'sly-db-next
    "o" 'sly-db-out
    "b" 'sly-db-break-on-return
    "a" 'sly-db-abort
    "q" 'sly-db-quit
    "A" 'sly-db-break-with-system-debugger
    "B" 'sly-db-break-with-default-debugger
    "P" 'sly-db-print-condition
    "C" 'sly-db-inspect-condition
    "g:" 'sly-interactive-eval
    "0" 'sly-db-invoke-restart-0
    "1" 'sly-db-invoke-restart-1
    "2" 'sly-db-invoke-restart-2
    "3" 'sly-db-invoke-restart-3
    "4" 'sly-db-invoke-restart-4
    "5" 'sly-db-invoke-restart-5
    "6" 'sly-db-invoke-restart-6
    "7" 'sly-db-invoke-restart-7
    "8" 'sly-db-invoke-restart-8
    "9" 'sly-db-invoke-restart-9)

  (evil-collection-define-key 'normal 'sly-inspector-mode-map
    [mouse-6] 'sly-inspector-pop
    [mouse-7] 'sly-inspector-next
    ;; TODO: `sly-inspector-next' and `sly-inspector-pop' should probably
    ;; just be bound to C-i and C-o.
    "gk" 'sly-inspector-pop
    (kbd "C-k") 'sly-inspector-pop
    "[[" 'sly-inspector-pop
    (kbd "C-o") 'sly-inspector-pop
    "gj" 'sly-inspector-next
    (kbd "C-j") 'sly-inspector-next
    "]]" 'sly-inspector-next
    (kbd "C-i") 'sly-inspector-next
    "K" 'sly-inspector-describe-inspectee
    "e" 'sly-inspector-eval
    "M-p" 'sly-inspector-history
    "gr" 'sly-inspector-reinspect
    "gv" 'sly-inspector-toggle-verbose
    (kbd "<tab>") 'forward-button
    (kbd "C-i") 'forward-button
    (kbd "<S-tab>") 'backward-button ; Emacs translates S-TAB
    (kbd "<backtab>") 'backward-button ; to BACKTAB on X.
    "." 'sly-edit-definition
    "gd" 'sly-edit-definition
    "gR" 'sly-inspector-fetch-all
    "q" 'sly-inspector-quit)

  (evil-collection-define-key 'normal 'sly-mode-map
    (kbd "K") 'sly-describe-symbol
    (kbd "C-t") 'sly-pop-find-definition-stack
    ;; goto
    "gd" 'sly-edit-definition
    "gz" 'sly-mrepl)

  (evil-collection-define-key 'normal 'sly-popup-buffer-mode-map
    ;; quit
    "q" 'quit-window

    (kbd "C-t") 'sly-pop-find-definition-stack

    ;; goto
    "gd" 'sly-edit-definition)

  (evil-collection-inhibit-insert-state 'sly-thread-control-mode-map)
  (evil-collection-define-key 'normal 'sly-thread-control-mode-map
    "a" 'sly-thread-attach
    "d" 'sly-thread-debug
    "x" 'sly-thread-kill
    "gr" 'sly-update-threads-buffer)

  (evil-collection-define-key 'normal 'sly-xref-mode-map
    (kbd "RET") 'sly-xref-goto
    (kbd "SPC") 'sly-xref-show
    "go" 'sly-show-xref
    (kbd "<tab>") 'forward-button
    (kbd "C-i") 'forward-button
    (kbd "<S-tab>") 'backward-button ; Emacs translates S-TAB
    (kbd "<backtab>") 'backward-button ; to BACKTAB on X.
    "gj" 'sly-xref-next-line
    "gk" 'sly-xref-prev-line
    (kbd "C-j") 'sly-xref-next-line
    (kbd "C-k") 'sly-xref-prev-line
    "]]" 'sly-xref-next-line
    "[[" 'sly-xref-prev-line
    "gr" 'sly-recompile-xref
    "gR" 'sly-recompile-all-xrefs
    ;; "r" 'sly-xref-retract ; TODO: Equivalent for Sly?
    )

  (evil-collection-define-key 'normal 'sly-mrepl-mode-map
    (kbd "RET") 'sly-mrepl-return
    "gj" 'sly-mrepl-next-prompt
    "gk" 'sly-mrepl-previous-prompt
    (kbd "C-j") 'sly-mrepl-next-prompt
    (kbd "C-k") 'sly-mrepl-previous-prompt
    "]]" 'sly-mrepl-next-prompt
    "[[" 'sly-mrepl-previous-prompt
    (kbd "C-p") 'sly-mrepl-previous-input-or-button
    (kbd "C-n") 'sly-mrepl-next-input-or-button)

  (add-hook 'sly-popup-buffer-mode-hook #'evil-normalize-keymaps))

(provide 'evil-collection-sly)
;;; evil-collection-sly.el ends here
