(in-package :cl-user)


(defpackage #:clob-templates
  (:use #:cl #:djula)
  (:export :render-blog :blog :not-found :blogmode :index))

(defpackage #:clob-connection-details
  (:use #:cl)
  (:export :*connection-details* :*database-type*))

(defpackage #:clob-handlers
  (:use #:cl #:clob-connection-details)
  (:export :start :handlers :retrieve-blog))
