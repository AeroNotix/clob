(in-package :clob-handlers)

(clsql:locally-enable-sql-reader-syntax)

(defun start ()
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242)))

(clsql-sys:def-view-class |blog-entry| ()
  ((id
    :type integer
    :column |id|
    :db-kind :key
    :db-constraints :not-null
    :initarg :id)
   (date
    :db-type "date"
    :column |date|
    :db-constraints :not-null
    :initarg :date)
   (blog-url
    :type (string 64)
    :column |blog_url|
    :db-constraints :not-null
    :initarg :url)
   (blog-title
    :type (string 64)
    :column |blog_title|
    :db-constraints :not-null
    :initarg :url)
   (blog-post
    :db-type "longtext"
    :column |blog_post|
    :db-constraints :not-null
    :initarg :post)))

(defmacro with-db (database &body body)
  `(clsql:with-database (,database *connection-details*
				   :database-type *database-type*
				   :pool t :if-exists :use)
     ,@body))

(hunchentoot:define-easy-handler (index :uri "/") ()
  (setf (hunchentoot:content-type*) "text/html")
  "<html><h3>Not implemented</h3></html>")

(defun extract-blog-title (str)
  (cl-ppcre:register-groups-bind (only)
      ("/blog/([A-Za-z0-9\-]+)/?" str)
    only))

(defun retrieve-blog (blog-name)
  (first (first (with-db db
	   (clsql:select '|blog-entry| :database db
			 :where [= [slot-value '|blog-entry| 'blog-url]
			 blog-name])))))

(defun blog-entry ()
  (let* ((blog-name (extract-blog-title (hunchentoot:request-uri* hunchentoot:*request*)))
	 (blog (retrieve-blog blog-name))
	 (string-stream (with-slots (blog-title blog-post) blog
			  (clob-templates:blog :blog_title blog-title :blog_post blog-post))))
    (get-output-stream-string string-stream)))

(defun handlers (&rest handlers)
  (dolist (handler handlers)
    (push handler hunchentoot:*dispatch-table*)))

(handlers
 (hunchentoot:create-regex-dispatcher "/blog/$?" #'(lambda () "<html><h3>B</h3></html>"))
 (hunchentoot:create-regex-dispatcher "/blog/[A-Za-z0-9\-]/?$" 'blog-entry))

(clsql:locally-disable-sql-reader-syntax)
