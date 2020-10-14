;;;; -*- mode: lisp -*-

(defsystem :woo-drakma-memleak
  :name "woo-drakma-memleak"
  :author "Azamat S. Kalimoulline"
  :license "GPL"
  :version "0.0.1.0"
  :description "Memory Leak Test with woo + drakma"
  :depends-on (#:bordeaux-threads
               #:clack
               #:drakma
               #:jonathan
               #:metabang-bind
               #:ningle
               #:optima
               #:vom
               #:woo)
  :components ((:module "src"
                        :components
                        ((:file "package")
                         (:file "main"
                          :depends-on ("package"))))))
