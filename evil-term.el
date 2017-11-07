;;; evil-term.el --- Evil bindings for term and ansi-term  -*- lexical-binding: t -*-

;; Copyright (C) 2017 Pierre Neidhardt

;; Author: Pierre Neidhardt <ambrevar@gmail.com>
;; Maintainer: James Nguyen <james@jojojames.com>, Pierre Neidhardt <ambrevar@gmail.com>
;; URL: https://github.com/jojojames/evil-collection
;; Version: 0.0.1
;; Package-Requires: ((emacs "25.1"))
;; Keywords: evil, term
;; HomePage: https://github.com/jojojames/evil-collection

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation; either version 3, or (at your
;; option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;; Evil integration for `term' and `ansi-term'.
;; This should also work for other terminal emulators such as `multi-term'.
;;
;; Switching to normal state will automatically switch to line mode.
;; Conversely, switching to insert state will automatically switch to char mode.

;;; Code:

(require 'evil)
(require 'term)

;;; TODO: Rebinding ESC has the drawback that programs like vi cannot use it anymore.
;;; Workaround: switch to Emacs state and double-press ESC.
;;; Otherwise leave ESC to "C-c C-j".
;;; Or bind char-mode ESC to "C-c C-x"?

(defun evil-term-escape-stay ()
  "Go back to normal state but don't move cursor backwards.
Moving cursor backwards is the default Vim behavior but
it is not appropriate in some cases like terminals."
  (setq-local evil-move-cursor-back nil))

(defun evil-term-char-mode-insert ()
  (interactive)
  (term-char-mode)
  (evil-insert-state))

(defun evil-term-char-mode-entry-function ()
  (when (get-buffer-process (current-buffer))
    (let (last-prompt)
      (save-excursion
        (goto-char (point-max))
        (when (= (line-beginning-position) (line-end-position))
          (ignore-errors (backward-char)))
        (setq last-prompt (max (term-bol nil) (line-beginning-position))))
      (when (>= (point) last-prompt)
        (term-char-mode)))))

(defun evil-term-sync-state-and-mode ()
  (add-hook 'evil-insert-state-entry-hook 'evil-term-char-mode-entry-function)
  (add-hook 'evil-insert-state-exit-hook 'term-line-mode))

(defun evil-term-setup ()
  (evil-set-initial-state 'term-mode 'insert)
  (add-hook 'term-mode-hook 'evil-term-sync-state-and-mode)
  (add-hook 'term-mode-hook 'evil-term-escape-stay)

  (evil-define-key 'normal term-mode-map
    (kbd "C-c C-k") 'evil-term-char-mode-insert
    (kbd "<return>") 'term-send-input

    (kbd "p") 'term-paste

    ;; motion
    "[" 'term-previous-prompt
    "]" 'term-next-prompt
    (kbd "C-k") 'term-previous-prompt
    (kbd "C-j") 'term-next-prompt
    ;; "0" 'term-bol ; "0" is meant to really go at the beginning of line.
    "^" 'term-bol
    "$" 'term-show-maximum-output))

(provide 'evil-term)
;;; evil-term.el ends here