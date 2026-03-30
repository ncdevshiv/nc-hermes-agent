(defpackage :nc-hermes-agent.core-tools
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.skills)
  (:export :init-core-tools))
(in-package :nc-hermes-agent.core-tools)

(defvar *current-agent-state* nil
  "Dynamically bound by the agent loop for tools that need access to the state (e.g. checkpointing).")

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

(defun tool-create-checkpoint (args)
  "Adapter for saving a checkpoint."
  (let ((filepath (gethash "filepath" args)))
    (if (and filepath *current-agent-state*)
        (progn
          (nc-hermes-agent.state:save-checkpoint *current-agent-state* filepath)
          (format nil "Checkpoint successfully created at ~A." filepath))
        "Error: 'filepath' missing or state unavailable.")))

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

    (let ((schema-ckpt (make-hash-table :test 'equal))
          (props-ckpt (make-hash-table :test 'equal))
          (prop-fp (make-hash-table :test 'equal)))
      (setf (gethash "type" prop-fp) "string")
      (setf (gethash "description" prop-fp) "The path of the file to save the checkpoint to (e.g., state.json).")
      (setf (gethash "filepath" props-ckpt) prop-fp)
      (setf (gethash "type" schema-ckpt) "object")
      (setf (gethash "properties" schema-ckpt) props-ckpt)
      (setf (gethash "required" schema-ckpt) '("filepath"))
      (register-tool "create_checkpoint"
                     "Saves the current agent memory and messages to a file."
                     schema-ckpt
                     #'tool-create-checkpoint))

    (format t "Core tools initialized.~%")))

;; Register as a skill module so it loads gracefully
(register-skill "core-tools" #'init-core-tools)
