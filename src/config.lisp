(defpackage :nc-hermes-agent.config
  (:use :cl)
  (:export :*config*
           :load-config
           :get-config-value))
(in-package :nc-hermes-agent.config)

(defvar *config* nil "The centralized configuration alist.")

(defun load-config (filepath)
  "Loads a configuration S-expression file and stores it in *config*."
  (with-open-file (stream filepath
                          :direction :input
                          :if-does-not-exist nil)
    (if stream
        (let* ((*read-eval* nil)
               (data (read stream nil nil)))
          (if (listp data)
              (setf *config* data)
              (error "Configuration must be an association list (S-expression).")))
        (error "Configuration file not found: ~a" filepath)))
  *config*)

(defun get-config-value (key &optional default)
  "Retrieves a value from *config* by key, returning DEFAULT if not found."
  (let ((pair (assoc key *config*)))
    (if pair
        (cdr pair)
        default)))
