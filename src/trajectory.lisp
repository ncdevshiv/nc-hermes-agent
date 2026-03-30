(defpackage :nc-hermes-agent.trajectory
  (:use :cl :nc-hermes-agent.config)
  (:export :log-action))
(in-package :nc-hermes-agent.trajectory)

(defun log-action (state-id role content)
  "Logs an agent trajectory action for Reinforcement Learning (RL) training."
  (let ((log-file (get-config-value :trajectory-log-file nil)))
    (when log-file
      (let ((payload (make-hash-table :test 'equal)))
        (setf (gethash "state_id" payload) state-id)
        (setf (gethash "role" payload) role)
        (setf (gethash "content" payload) content)
        (setf (gethash "timestamp" payload) (get-universal-time))

        ;; Append the JSON record as a line (JSONL format)
        (with-open-file (stream log-file
                                :direction :output
                                :if-exists :append
                                :if-does-not-exist :create)
          (shasht:write-json payload stream)
          (terpri stream))))))
