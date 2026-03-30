(defpackage :nc-hermes-agent.llm
  (:use :cl :nc-hermes-agent.config :nc-hermes-agent.state)
  (:export :generate-response))
(in-package :nc-hermes-agent.llm)

(defun get-openai-api-key ()
  "Retrieves the OpenAI API key from the environment."
  (let ((key (uiop:getenv "OPENAI_API_KEY")))
    (unless key
      (error "OPENAI_API_KEY environment variable is not set."))
    key))

(defun build-request-payload (model messages tools)
  "Creates the JSON payload for the OpenAI Chat Completions API."
  (let ((payload (make-hash-table :test 'equal)))
    (setf (gethash "model" payload) model)
    (setf (gethash "messages" payload) messages)
    (when tools
      (setf (gethash "tools" payload) tools))
    payload))

(defun generate-response (state &key (model "gpt-4o") tools)
  "Sends the agent state to an OpenAI-compatible API and appends the response."
  (let* ((endpoint (get-config-value :api-endpoint "https://api.openai.com/v1/chat/completions"))
         (api-key (get-openai-api-key))
         (payload (build-request-payload model (get-messages state) tools))
         (json-payload (shasht:write-json payload nil)))
    (handler-case
        (multiple-value-bind (response-body status headers uri stream)
            (dex:post endpoint
                      :headers `(("Authorization" . ,(format nil "Bearer ~a" api-key))
                                 ("Content-Type" . "application/json"))
                      :content json-payload)
          (declare (ignore headers uri stream))
          (if (= status 200)
              (let* ((json-response (shasht:read-json response-body))
                     (choices (gethash "choices" json-response))
                     (first-choice (when choices (first choices)))
                     (message (when first-choice (gethash "message" first-choice)))
                     (content (when message (gethash "content" message)))
                     (role (when message (gethash "role" message))))
                (if content
                    (add-message state role content)
                    (error "Invalid JSON response structure: ~a" response-body)))
              (error "API returned HTTP ~a: ~a" status response-body)))
      (dex:http-request-failed (e)
        (error "API Request failed: ~a" e)))))
