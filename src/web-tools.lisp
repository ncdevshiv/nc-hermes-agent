(defpackage :nc-hermes-agent.web-tools
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.skills)
  (:export :init-web-tools))
(in-package :nc-hermes-agent.web-tools)

(defun tool-fetch-url (args)
  (let ((url (gethash "url" args)))
    (if url
        (handler-case
            (dex:get url)
          (dex:http-request-failed (e)
            (format nil "Failed to fetch URL ~A: ~A" url e)))
        "Error: 'url' argument missing.")))

(defun init-web-tools ()
  "Registers foundational web scraping tools."
  (let ((schema-fetch (make-hash-table :test 'equal))
        (props-fetch (make-hash-table :test 'equal))
        (prop-url (make-hash-table :test 'equal)))
    (setf (gethash "type" prop-url) "string")
    (setf (gethash "description" prop-url) "The URL to fetch the content from.")
    (setf (gethash "url" props-fetch) prop-url)
    (setf (gethash "type" schema-fetch) "object")
    (setf (gethash "properties" schema-fetch) props-fetch)
    (setf (gethash "required" schema-fetch) '("url"))
    (register-tool "view_text_website" "Fetches the text content of a website." schema-fetch #'tool-fetch-url))
  (format t "Web tools initialized.~%"))

(register-skill "web-tools" #'init-web-tools)
