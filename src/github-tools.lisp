(defpackage :nc-hermes-agent.github-tools
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.skills :nc-hermes-agent.config)
  (:export :init-github-tools))
(in-package :nc-hermes-agent.github-tools)

(defun get-github-token ()
  (or (uiop:getenv "GITHUB_TOKEN") (get-config-value :github-token)))

(defun tool-github-issue (args)
  (let ((owner (gethash "owner" args))
        (repo (gethash "repo" args))
        (issue-number (gethash "issue_number" args))
        (token (get-github-token)))
    (if (and owner repo issue-number token)
        (handler-case
            (let* ((endpoint (format nil "https://api.github.com/repos/~A/~A/issues/~A" owner repo issue-number))
                   (response (dex:get endpoint
                                      :headers `(("Authorization" . ,(format nil "Bearer ~A" token))
                                                 ("Accept" . "application/vnd.github.v3+json")))))
              response)
          (dex:http-request-failed (e)
            (format nil "GitHub API Request failed: ~A" e)))
        "Error: 'owner', 'repo', 'issue_number' missing or GITHUB_TOKEN not configured.")))

(defun init-github-tools ()
  "Registers basic GitHub interaction tools if a token is available."
  (if (get-github-token)
      (let ((schema-issue (make-hash-table :test 'equal))
            (props-issue (make-hash-table :test 'equal))
            (prop-owner (make-hash-table :test 'equal))
            (prop-repo (make-hash-table :test 'equal))
            (prop-num (make-hash-table :test 'equal)))

        (setf (gethash "type" prop-owner) "string")
        (setf (gethash "description" prop-owner) "Repository owner or organization.")
        (setf (gethash "type" prop-repo) "string")
        (setf (gethash "description" prop-repo) "Repository name.")
        (setf (gethash "type" prop-num) "integer")
        (setf (gethash "description" prop-num) "Issue number to fetch.")

        (setf (gethash "owner" props-issue) prop-owner)
        (setf (gethash "repo" props-issue) prop-repo)
        (setf (gethash "issue_number" props-issue) prop-num)

        (setf (gethash "type" schema-issue) "object")
        (setf (gethash "properties" schema-issue) props-issue)
        (setf (gethash "required" schema-issue) '("owner" "repo" "issue_number"))

        (register-tool "get_github_issue" "Fetches details of a GitHub issue." schema-issue #'tool-github-issue)
        (format t "GitHub tools initialized.~%"))
      (format t "GitHub tools skipped (No GITHUB_TOKEN found).~%")))

(register-skill "github-tools" #'init-github-tools)
