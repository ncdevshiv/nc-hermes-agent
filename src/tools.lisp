(defpackage :nc-hermes-agent.tools
  (:use :cl)
  (:export :register-tool
           :execute-tool
           :get-tools
           :clear-tools))
(in-package :nc-hermes-agent.tools)

(defvar *tool-registry* (make-hash-table :test 'equal)
  "Central registry for available tools.")

(defun register-tool (name description parameters-schema function)
  "Registers a new tool in the global registry."
  (let ((tool (make-hash-table :test 'equal)))
    (setf (gethash "type" tool) "function")
    (let ((function-def (make-hash-table :test 'equal)))
      (setf (gethash "name" function-def) name)
      (setf (gethash "description" function-def) description)
      (setf (gethash "parameters" function-def) parameters-schema)
      (setf (gethash "function" tool) function-def))
    (setf (gethash name *tool-registry*) (cons tool function))))

(defun get-tools ()
  "Returns a list of registered tools suitable for API payloads."
  (loop for key being the hash-keys of *tool-registry*
        for (tool . function) being the hash-values of *tool-registry*
        collect tool))

(defun execute-tool (name arguments-json-string)
  "Executes a registered tool with the given JSON arguments string."
  (let ((entry (gethash name *tool-registry*)))
    (if entry
        (let* ((function (cdr entry))
               (args (shasht:read-json arguments-json-string)))
          (apply function (loop for val being the hash-values of args collect val)))
        (error "Tool ~a not found in registry." name))))

(defun clear-tools ()
  "Empties the tool registry."
  (clrhash *tool-registry*))
