(defpackage :nc-hermes-agent.search-tools
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.skills :nc-hermes-agent.config)
  (:export :init-search-tools))
(in-package :nc-hermes-agent.search-tools)

(defun get-tavily-api-key ()
  (or (uiop:getenv "TAVILY_API_KEY") (get-config-value :tavily-api-key)))

(defun tool-web-search (args)
  (let ((query (gethash "query" args))
        (api-key (get-tavily-api-key)))
    (if (and query api-key)
        (handler-case
            (let* ((endpoint "https://api.tavily.com/search")
                   (payload (make-hash-table :test 'equal))
                   (_ (setf (gethash "api_key" payload) api-key))
                   (_ (setf (gethash "query" payload) query))
                   (json-payload (shasht:write-json payload nil)))
              (declare (ignore _))
              (multiple-value-bind (response-body status headers uri stream)
                  (dex:post endpoint
                            :headers '(("Content-Type" . "application/json"))
                            :content json-payload)
                (declare (ignore headers uri stream))
                (if (= status 200)
                    response-body
                    (format nil "Search failed with status ~A: ~A" status response-body))))
          (dex:http-request-failed (e)
            (format nil "Search API Request failed: ~A" e)))
        "Error: 'query' argument missing or TAVILY_API_KEY not configured.")))

(defun init-search-tools ()
  "Registers the Tavily web search tool if an API key is available."
  (if (get-tavily-api-key)
      (let ((schema-search (make-hash-table :test 'equal))
            (props-search (make-hash-table :test 'equal))
            (prop-query (make-hash-table :test 'equal)))
        (setf (gethash "type" prop-query) "string")
        (setf (gethash "description" prop-query) "The query string to search for on the web.")
        (setf (gethash "query" props-search) prop-query)
        (setf (gethash "type" schema-search) "object")
        (setf (gethash "properties" schema-search) props-search)
        (setf (gethash "required" schema-search) '("query"))
        (register-tool "web_search" "Searches the web for up-to-date information." schema-search #'tool-web-search)
        (format t "Search tools initialized.~%"))
      (format t "Search tools skipped (No TAVILY_API_KEY found).~%")))

(register-skill "search-tools" #'init-search-tools)
