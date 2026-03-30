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
