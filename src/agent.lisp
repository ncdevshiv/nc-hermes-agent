(defpackage :nc-hermes-agent.agent
  (:use :cl :nc-hermes-agent.config)
  (:export :start-agent
           :stop-agent
           :agent-loop))
(in-package :nc-hermes-agent.agent)

(defvar *agent-running* nil "State variable tracking whether the agent loop is active.")

(defun log-level-weight (level)
  (case level
    (:debug 0)
    (:info 1)
    (:warn 2)
    (:error 3)
    (t 1)))

(defun log-msg (level message &rest args)
  "Simple centralized logging."
  (let ((config-level (get-config-value :log-level :info)))
    (when (>= (log-level-weight level) (log-level-weight config-level))
      (format t "[~a] ~a~%" level (apply #'format nil message args)))))

(defun agent-loop ()
  "The core processing loop of the agent."
  (log-msg :info "Agent loop started.")
  (loop while *agent-running* do
    (log-msg :debug "Agent tick...")
    (sleep 1))
  (log-msg :info "Agent loop stopped."))

(defun start-agent ()
  "Starts the Hermes agent."
  (if *agent-running*
      (log-msg :warn "Agent is already running.")
      (progn
        (log-msg :info "Starting Hermes Agent version ~a" (get-config-value :version "unknown"))
        (setf *agent-running* t)
        (bordeaux-threads:make-thread #'agent-loop :name "hermes-agent-loop"))))

(defun stop-agent ()
  "Signals the agent to stop running."
  (when *agent-running*
    (log-msg :info "Stopping agent...")
    (setf *agent-running* nil)))
