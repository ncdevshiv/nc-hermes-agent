(defpackage :nc-hermes-agent.cli
  (:use :cl :nc-hermes-agent.agent)
  (:export :parse-args))
(in-package :nc-hermes-agent.cli)

;; A lightweight CLI parser avoiding heavy dependencies
;; Can easily drop in adopt/clingon later if needed.

(defun parse-args (argv)
  "Parses basic CLI arguments and initializes the agent."
  ;; SBCL command line args might include the executable name, handle properly
  (let ((args (rest argv))
        (resume-file nil))
    (if (and args (member "--help" args :test #'string=))
        (progn
          (format t "Usage: hermes-agent [--help] [--resume <checkpoint.json>]~%")
          (uiop:quit 0))
        (progn
          ;; Very basic arg parsing for --resume
          (let ((resume-idx (position "--resume" args :test #'string=)))
            (when (and resume-idx (< (1+ resume-idx) (length args)))
              (setf resume-file (nth (1+ resume-idx) args))))

          (format t "Hermes CLI Starting...~%")
          resume-file))))
