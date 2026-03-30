(defpackage :nc-hermes-agent/tests
  (:use :cl :rove :nc-hermes-agent.config :nc-hermes-agent.agent))
(in-package :nc-hermes-agent/tests)

(deftest test-config
  (testing "Testing S-expression config loading"
    (let ((temp-config "test-config.lisp")
          (test-data '((:key1 . "value1") (:key2 . 42))))
      (with-open-file (s temp-config :direction :output :if-exists :supersede)
        (write test-data :stream s))

      (let ((loaded (load-config temp-config)))
        (ok (equal loaded test-data) "Config should match written data")
        (ok (equal (get-config-value :key1) "value1") "Should fetch key1 string")
        (ok (= (get-config-value :key2) 42) "Should fetch key2 number")
        (ok (null (get-config-value :non-existent)) "Should return nil for missing keys")
        (ok (equal (get-config-value :missing "default") "default") "Should return default if missing"))

      (delete-file temp-config))))

(deftest test-agent-state
  (testing "Agent starts and stops"
    (let ((nc-hermes-agent.agent::*agent-running* nil))
      (ok (null nc-hermes-agent.agent::*agent-running*) "Agent should be stopped initially")

      (setf nc-hermes-agent.agent::*agent-running* t)
      (ok nc-hermes-agent.agent::*agent-running* "Agent should be running after start flag")

      (stop-agent)
      (ok (null nc-hermes-agent.agent::*agent-running*) "Agent should stop after stop-agent"))))

(deftest test-checkpoints
  (testing "State saving and loading from JSON checkpoints"
    (let* ((temp-file "test-checkpoint.json")
           (state (nc-hermes-agent.state:make-agent-state)))
      (nc-hermes-agent.state:add-message state "user" "Hello Lisp!")
      (nc-hermes-agent.state:add-message state "assistant" "Hi!")

      (ok (= (length (nc-hermes-agent.state:get-messages state)) 2) "Should have 2 messages")

      (nc-hermes-agent.state:save-checkpoint state temp-file)
      (ok (probe-file temp-file) "Checkpoint file should exist")

      (let ((loaded-state (nc-hermes-agent.state:load-checkpoint temp-file)))
        (ok (= (length (nc-hermes-agent.state:get-messages loaded-state)) 2) "Loaded state should have 2 messages")
        ;; Shasht deserializes JSON arrays into Lisp vectors by default, so we coerce it back or access it as an array
        (let* ((msgs (nc-hermes-agent.state:get-messages loaded-state))
               (first-msg (if (vectorp msgs) (aref msgs 0) (first msgs))))
          (ok (equal (gethash "role" first-msg) "user") "Role should match")
          (ok (equal (gethash "content" first-msg) "Hello Lisp!") "Content should match")))

      (delete-file temp-file))))
