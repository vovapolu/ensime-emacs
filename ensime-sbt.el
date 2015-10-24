;;; ensime-sbt.el --- SBT support for ENSIME -*- lexical-binding: t -*-

;; Copyright (C) 2015 ENSIME authors
;; License: http://www.gnu.org/licenses/gpl.html

;;; Commentary:
;;
;;  SBT should be an optional system dependency of ENSIME (we try to
;;  be build tool agnostic, even if we have a favourite) and ideally
;;  all sbt-related content should be contained to this file.
;;
;;; Code:

(eval-when-compile
  (require 'cl)
  (require 'ensime-macros))

(require 'sbt-mode)

(defgroup ensime-sbt nil
  "Support for sbt build REPL."
  :group 'ensime
  :prefix "ensime-sbt-")

(defcustom ensime-sbt-perform-on-save nil
  "Which (if any) sbt action to perform when a file is saved."
  :type '(choice (const nil) string)
  :group 'ensime-sbt)

(defun ensime-sbt ()
  "Switch to the sbt shell (create if necessary) if or if already there, back.
   If already there but the process is dead, restart the process. "
  (interactive)
  (ensime-with-conn-interactive
   conn
   (with-current-buffer (sbt-start)
     (setq ensime-buffer-connection conn)
     (add-hook 'ensime-source-buffer-saved-hook 'ensime-sbt-maybe-auto-compile)
     (add-hook 'comint-output-filter-functions 'ensime-inf-postoutput-filter))))

(defun ensime-sbt-maybe-auto-compile ()
  (when (and
         (ensime-connected-p)
         ensime-sbt-perform-on-save
         (get-buffer (sbt:buffer-name)))
    (sbt-command ensime-sbt-perform-on-save)))

(defun ensime-sbt-switch ()
  (interactive)
  (ensime-sbt))

(defun ensime-sbt-do-compile ()
  (interactive)
  (sbt-command "compile"))

(defun ensime-sbt-do-run ()
  (interactive)
  (sbt-command "run"))

(defun ensime-sbt-do-clean ()
  (interactive)
  (sbt-command "clean"))

(defun ensime-sbt-do-package ()
  (interactive)
  (sbt-command "package"))

(defun ensime-sbt-do-test ()
  (interactive)
  (sbt-command "test"))

(defun ensime-sbt-do-test-quick ()
  (interactive)
  (sbt-command "testQuick"))

(defun ensime-sbt-do-test-only ()
  (interactive)
  (let* ((impl-class
            (or (ensime-top-level-class-closest-to-point)
                (return (message "Could not find top-level class"))))
	 (cleaned-class (replace-regexp-in-string "<empty>\\." "" impl-class))
	 (command (concat "test-only" " " cleaned-class)))
    (sbt-command command)))

(provide 'ensime-sbt)

;;; ensime-sbt.el ends here
