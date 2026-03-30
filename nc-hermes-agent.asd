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
               "alexandria"
               "hunchentoot")
  :components ((:module "src"
                :components
                ((:file "config")
                 (:file "state")
                 (:file "tools")
                 (:file "skills" :depends-on ("tools"))
                 (:file "core-tools" :depends-on ("skills" "tools"))
                 (:file "llm" :depends-on ("config" "state"))
                 (:file "mcp" :depends-on ("config" "tools"))
                 (:file "agent" :depends-on ("config" "state" "llm" "tools" "skills" "core-tools"))
                 (:file "gateway" :depends-on ("config" "agent" "state"))
                 (:file "cli" :depends-on ("agent"))
                 (:file "main" :depends-on ("agent" "gateway" "cli")))))
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
