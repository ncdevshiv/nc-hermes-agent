(defpackage :nc-hermes-agent.mcp-client
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.skills :nc-hermes-agent.config)
  (:export :connect-mcp-server
           :init-mcp-servers))
(in-package :nc-hermes-agent.mcp-client)

(defun execute-mcp-call (server-name executable args-json command-string)
  "Simulates making an RPC call to an MCP server."
  (let ((input (shasht:write-json `(("jsonrpc" . "2.0")
                                     ("id" . 1)
                                     ("method" . ,command-string)
                                     ("params" . ,(shasht:read-json args-json)))
                                  nil)))
    ;; In a real implementation we would pipe this input directly to the stdio process
    ;; For now, since we only have basic uiop:run-program, we execute a one-off call:
    (let ((output (make-string-output-stream)))
      (uiop:run-program (list executable input)
                        :output output
                        :error-output *error-output*
                        :ignore-error-status t)
      (get-output-stream-string output))))

(defun connect-mcp-server (server-name executable)
  "Initializes connection to an MCP server, queries tools, and registers them."
  (format t "Connecting to MCP Server ~A (~A)...~%" server-name executable)

  ;; Here we would query the server's tools (`tools/list` protocol message).
  ;; Because we don't have a real running MCP server target right now, we
  ;; just simulate registering a generic tool that routes to it.

  (let ((schema (make-hash-table :test 'equal))
        (props (make-hash-table :test 'equal))
        (prop-args (make-hash-table :test 'equal)))
    (setf (gethash "type" prop-args) "object")
    (setf (gethash "description" prop-args) "Arguments to pass to the MCP tool.")
    (setf (gethash "mcp_arguments" props) prop-args)
    (setf (gethash "type" schema) "object")
    (setf (gethash "properties" schema) props)

    (let ((tool-executor (lambda (args)
                           (execute-mcp-call server-name executable args "execute"))))
      (register-tool (format nil "~A_invoke" server-name)
                     (format nil "Invokes a command on the ~A MCP server." server-name)
                     schema
                     tool-executor)
      (format t "Registered ~A MCP tools.~%" server-name))))

(defun init-mcp-servers ()
  "Reads MCP configuration and starts clients."
  (let ((servers (get-config-value :mcp-servers nil)))
    (loop for server in servers
          do (let ((name (cdr (assoc :name server)))
                   (cmd (cdr (assoc :command server))))
               (when (and name cmd)
                 (connect-mcp-server name cmd))))))

;; We register the MCP connection bootstrapper as a skill module
(register-skill "mcp-client" #'init-mcp-servers)
