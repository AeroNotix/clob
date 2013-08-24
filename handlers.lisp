(in-package :clob-handlers)


(defun start ()
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242)))

(hunchentoot:define-easy-handler (say-yo :uri "/") ()
  (setf (hunchentoot:content-type*) "text/html")
  "<html><h3>Not implemented</h3></html>")
