(defpackage :nc-hermes-agent.agent
  (:use :cl :nc-hermes-agent.config :nc-hermes-agent.state :nc-hermes-agent.llm :nc-hermes-agent.tools :nc-hermes-agent.skills :nc-hermes-agent.core-tools :nc-hermes-agent.file-tools :nc-hermes-agent.web-tools :nc-hermes-agent.mcp-client)
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
  (let ((state (make-agent-state)))
    (loop while *agent-running* do
      (log-msg :debug "Agent tick...")
      (sleep 1)))
  (log-msg :info "Agent loop stopped."))

(defun start-agent ()
  "Starts the Hermes agent."
  (if *agent-running*
      (log-msg :warn "Agent is already running.")
      (progn
        (log-msg :info "Starting Hermes Agent version ~a" (get-config-value :version "unknown"))
        ;; Initialize all registered skill modules (this includes tools and mcp-clients)
        (loop for skill-name in (get-active-skills)
              do (let ((init-fn (gethash skill-name nc-hermes-agent.skills::*skill-registry*)))
                   (when init-fn (funcall init-fn))))
        (setf *agent-running* t)
        (bordeaux-threads:make-thread #'agent-loop :name "hermes-agent-loop"))))

(defun stop-agent ()
  "Signals the agent to stop running."
  (when *agent-running*
    (log-msg :info "Stopping agent...")
    (setf *agent-running* nil)))
