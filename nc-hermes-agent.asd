(in-package :asdf-user)

(defsystem "nc-hermes-agent"
  :description "Hermes Agent rewritten in Common Lisp"
  :version "0.1.0"
  :author "NC"
  :license "MIT"
  :depends-on ("dexador"
               "shasht"
               "bordeaux-threads"
               "lparallel"
               "str"
               "alexandria")
  :components ((:module "src"
                :components
                ((:file "config")
                 (:file "agent" :depends-on ("config"))
                 (:file "main" :depends-on ("agent")))))
  :in-order-to ((test-op (test-op "nc-hermes-agent/tests"))))

(defsystem "nc-hermes-agent/tests"
  :description "Tests for the Hermes Agent"
  :author "NC"
  :license "MIT"
  :depends-on ("nc-hermes-agent"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main-test"))))
  :perform (test-op (op c) (symbol-call :rove :run c)))
