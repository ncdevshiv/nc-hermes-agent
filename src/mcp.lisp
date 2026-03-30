(defpackage :nc-hermes-agent.mcp
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.config)
  (:export :register-mcp-tool))
(in-package :nc-hermes-agent.mcp)

;; Model Context Protocol Integration (Basic Server Implementation)

(defun register-mcp-tool (server-name tool-name description schema execute-fn)
  "Registers a tool retrieved from an MCP server directly into the agent's toolset."
  ;; In a full implementation, execute-fn would wrap a json-rpc call to the MCP server.
  (let ((namespaced-tool (format nil "~a_~a" server-name tool-name)))
    (register-tool namespaced-tool description schema execute-fn)
    (format t "Registered MCP tool: ~A~%" namespaced-tool)))
