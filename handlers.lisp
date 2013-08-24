(in-package :clob-handlers)

(defun start ()
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242)))

(hunchentoot:define-easy-handler (index :uri "/") ()
  (setf (hunchentoot:content-type*) "text/html")
  "<html><h3>Not implemented</h3></html>")

(defun extract-blog-title (str)
  (cl-ppcre:register-groups-bind (only)
      ("/blog/([A-Za-z0-9\-]+)/?" str)
    only))

(defun handlers (&rest handlers)
  (dolist (handler handlers)
    (push handler hunchentoot:*dispatch-table*)))

(handlers
 (hunchentoot:create-prefix-dispatcher "/blog/" #'(lambda () "<html><h3>Lolwut</h3></html>")))
