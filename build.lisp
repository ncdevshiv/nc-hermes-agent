(in-package :cl-user)

(format t "Ensuring Quicklisp is loaded...~%")
;; Quicklisp should be loaded globally in standard SBCL environments
#-quicklisp
(eval-when (:compile-toplevel :load-toplevel :execute)
  (let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                         (user-homedir-pathname))))
    (when (probe-file quicklisp-init)
      (load quicklisp-init))))

;; Load ASDF definitions in current directory
(pushnew (truename ".") asdf:*central-registry* :test #'equal)

(format t "Loading nc-hermes-agent system...~%")
(ql:quickload :nc-hermes-agent)

(format t "Saving executable...~%")
(sb-ext:save-lisp-and-die "bin/hermes-agent"
                          :toplevel #'nc-hermes-agent.main:main
                          :executable t
                          :save-runtime-options t)
