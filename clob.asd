(asdf:defsystem #:clob
  :author "Aaron France <aaron.l.france@gmail.com>"
  :description "Small blogging engine."
  :components
  ((:file "packages")
   (:file "connection-details" :depends-on ("packages"))
   (:file "handlers"           :depends-on ("packages" "connection-details"))
   (:module :templates)
   (:module :static))
   :depends-on (#:hunchentoot #:clsql))
