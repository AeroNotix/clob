(asdf:defsystem #:clob
  :author "Aaron France <aaron.l.france@gmail.com>"
  :description "Small blogging engine."
  :components
  ((:file "packages")
   (:file "handlers"    :depends-on ("packages")))
   :depends-on (#:hunchentoot))
