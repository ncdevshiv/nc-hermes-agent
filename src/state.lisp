(defpackage :nc-hermes-agent.state
  (:use :cl)
  (:export :make-agent-state
           :add-message
           :get-messages
           :clear-messages
           :save-checkpoint
           :load-checkpoint))
(in-package :nc-hermes-agent.state)

(defclass agent-state ()
  ((id :initform (format nil "state-~A" (get-universal-time))
       :accessor agent-id)
   (messages :initarg :messages
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
  ;; Store as hash-table for accurate JSON object serialization by Shasht
  (let ((msg (make-hash-table :test 'equal)))
    (setf (gethash "role" msg) role)
    (setf (gethash "content" msg) content)
    (setf (agent-messages state)
          (append (agent-messages state) (list msg)))
    msg))

(defun get-messages (state)
  "Retrieves all messages."
  (agent-messages state))

(defun clear-messages (state)
  "Clears the message history."
  (setf (agent-messages state) nil))

(defun save-checkpoint (state filepath)
  "Serializes the agent's messages to a JSON file."
  (let ((payload (make-hash-table :test 'equal)))
    (setf (gethash "messages" payload) (agent-messages state))
    (with-open-file (stream filepath
                            :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
      (shasht:write-json payload stream))
    (format t "Checkpoint saved to ~A~%" filepath)
    filepath))

(defun load-checkpoint (filepath)
  "Creates a new agent state populated from a JSON checkpoint file."
  (if (probe-file filepath)
      (let* ((json-string (alexandria:read-file-into-string filepath))
             (payload (shasht:read-json json-string))
             (messages (gethash "messages" payload))
             (state (make-agent-state)))
        (when messages
          (setf (agent-messages state) messages))
        (format t "Checkpoint loaded from ~A~%" filepath)
        state)
      (error "Checkpoint file ~A not found." filepath)))
