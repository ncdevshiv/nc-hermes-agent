(defpackage :nc-hermes-agent.skills
  (:use :cl :nc-hermes-agent.tools)
  (:export :register-skill
           :get-active-skills))
(in-package :nc-hermes-agent.skills)

(defvar *skill-registry* (make-hash-table :test 'equal)
  "Central registry for pluggable skills.")

(defun register-skill (skill-name initialize-fn)
  "Registers a skill module. The initialize-fn is expected to register tools."
  (setf (gethash skill-name *skill-registry*) initialize-fn)
  (format t "Skill ~A registered.~%" skill-name))

(defun get-active-skills ()
  "Returns a list of names for all registered skills."
  (loop for k being the hash-keys of *skill-registry* collect k))
