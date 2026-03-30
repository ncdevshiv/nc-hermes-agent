(defpackage :nc-hermes-agent.cli
  (:use :cl :nc-hermes-agent.agent)
  (:export :parse-args))
(in-package :nc-hermes-agent.cli)

;; A lightweight CLI parser avoiding heavy dependencies
;; Can easily drop in adopt/clingon later if needed.

(defun parse-args (argv)
  "Parses basic CLI arguments and initializes the agent."
  ;; SBCL command line args might include the executable name, handle properly
  (let ((args (rest argv)))
    (if (and args (member "--help" args :test #'string=))
        (progn
          (format t "Usage: hermes-agent [--help] [start]~%")
          (uiop:quit 0))
        ;; Standard startup behavior defaults to starting the agent
        (progn
          (format t "Hermes CLI Starting...~%")
          t))))
