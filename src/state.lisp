(defpackage :nc-hermes-agent.state
  (:use :cl)
  (:export :make-agent-state
           :add-message
           :get-messages
           :clear-messages))
(in-package :nc-hermes-agent.state)

(defclass agent-state ()
  ((messages :initarg :messages
             :initform nil
             :accessor agent-messages
             :documentation "List of message alists (role and content).")
   (memory :initarg :memory
           :initform (make-hash-table :test 'equal)
           :accessor agent-memory
           :documentation "Key-value store for agent context.")))

(defun make-agent-state ()
  "Creates a new, empty agent state."
  (make-instance 'agent-state))

(defun add-message (state role content)
  "Appends a message to the agent's state."
  ;; Store as alist for easy JSON serialization
  (let ((msg `(("role" . ,role) ("content" . ,content))))
    (setf (agent-messages state)
          (append (agent-messages state) (list msg)))
    msg))

(defun get-messages (state)
  "Retrieves all messages."
  (agent-messages state))

(defun clear-messages (state)
  "Clears the message history."
  (setf (agent-messages state) nil))
