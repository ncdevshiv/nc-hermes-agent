(defpackage :nc-hermes-agent.core-tools
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.skills)
  (:export :init-core-tools))
(in-package :nc-hermes-agent.core-tools)

(defun execute-bash-command (command)
  "Executes a simple bash command natively."
  (let ((output (make-string-output-stream)))
    (uiop:run-program command
                      :output output
                      :error-output output
                      :ignore-error-status t)
    (get-output-stream-string output)))

(defun tool-execute-shell (args)
  "Adapter mapping JSON arguments to shell executor."
  (let ((command (gethash "command" args)))
    (if command
        (execute-bash-command command)
        "Error: 'command' argument missing.")))

(defun init-core-tools ()
  "Registers foundational built-in tools."
  (let ((schema-execute-shell
         (make-hash-table :test 'equal)))
    (setf (gethash "type" schema-execute-shell) "object")
    (setf (gethash "required" schema-execute-shell) '("command"))
    (let ((props (make-hash-table :test 'equal)))
      (let ((cmd-prop (make-hash-table :test 'equal)))
        (setf (gethash "type" cmd-prop) "string")
        (setf (gethash "description" cmd-prop) "The bash command to execute.")
        (setf (gethash "command" props) cmd-prop))
      (setf (gethash "properties" schema-execute-shell) props))

    (register-tool "execute_shell"
                   "Executes a bash command and returns the output."
                   schema-execute-shell
                   #'tool-execute-shell)
    (format t "Core tools initialized.~%")))

;; Register as a skill module so it loads gracefully
(register-skill "core-tools" #'init-core-tools)
