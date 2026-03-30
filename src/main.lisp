(defpackage :nc-hermes-agent.main
  (:use :cl :nc-hermes-agent.config :nc-hermes-agent.agent :nc-hermes-agent.gateway :nc-hermes-agent.cli)
  (:export :main))
(in-package :nc-hermes-agent.main)

(defun load-system-config ()
  "Attempts to load configuration from common paths or environment."
  ;; Read from environment variable or default to config.example.lisp
  (let ((config-file (or (uiop:getenv "HERMES_CONFIG") "config.example.lisp")))
    (format t "Loading configuration from ~a~%" config-file)
    (handler-case (load-config config-file)
      (error (e)
        (format *error-output* "Failed to load config: ~a~%" e)
        (uiop:quit 1)))))

(defun main ()
  "Entry point for the compiled executable."
  (parse-args (uiop:command-line-arguments))
  (format t "Initializing Hermes Lisp Agent...~%")
  (load-system-config)
  (start-agent)
  (start-gateway)
  (format t "Press Ctrl+C to exit.~%")
  (handler-case
      (loop (sleep 1))
    (sb-sys:interactive-interrupt ()
      (stop-agent)
      (stop-gateway)
      (format t "~%Shutting down gracefully.~%")
      (uiop:quit 0))))
