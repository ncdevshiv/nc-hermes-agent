(defpackage :nc-hermes-agent.gateway
  (:use :cl :nc-hermes-agent.config :hunchentoot :nc-hermes-agent.state :nc-hermes-agent.agent)
  (:export :start-gateway
           :stop-gateway))
(in-package :nc-hermes-agent.gateway)

(defvar *server* nil "The Hunchentoot server instance.")

(define-easy-handler (health :uri "/health") ()
  (setf (content-type*) "application/json")
  (shasht:write-json '(:status "ok" :service "hermes-agent-gateway") nil))

(define-easy-handler (status :uri "/api/status") ()
  (setf (content-type*) "application/json")
  (shasht:write-json `(:running ,(if nc-hermes-agent.agent::*agent-running* t nil)
                       :version ,(get-config-value :version "unknown"))
                     nil))

(defun start-gateway ()
  "Starts the HTTP gateway server."
  (let ((port (get-config-value :gateway-port 8080)))
    (if *server*
        (format t "Gateway already running on port ~A~%" port)
        (progn
          (format t "Starting Hermes Gateway on port ~A~%" port)
          (setf *server* (make-instance 'easy-acceptor :port port))
          (start *server*)))))

(defun stop-gateway ()
  "Stops the HTTP gateway server."
  (when *server*
    (format t "Stopping Hermes Gateway...~%")
    (stop *server*)
    (setf *server* nil)))
