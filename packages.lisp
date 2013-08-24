(in-package :cl-user)

(defpackage #:clob-connection-details
  (:use #:cl)
  (:export :*connection-details* :*database-type*))

(defpackage #:clob-handlers
  (:use #:cl #:clob-connection-details)
  (:export :start :handlers))
