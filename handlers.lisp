(in-package :clob-handlers)

(clsql:locally-enable-sql-reader-syntax)

(defun start ()
  "Starts the web application."
  (hunchentoot:start (make-instance 'hunchentoot:easy-acceptor :port 4242)))

;; '|blog-entry| represents a single entry in the blog database. We
;; unfortunately have to use |symbol| because of how cl-sql works: It
;; requires that symbols (note: no |) are uppercased field names in
;; the database, same goes for the table names.
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
  "This macro helps interpolate forms into a blog which is sure to
  contain a reference to a live database connection."
  `(clsql:with-database (,database *connection-details*
                         :database-type *database-type*
                         :pool t :if-exists :use)
     ,@body))

(defun static-file-handler (where &key (uri "/static/") (content-type nil))
  (hunchentoot:create-folder-dispatcher-and-handler uri where content-type))

(defun extract-blog-title (str)
  "When a request is made to '/blog/something/' we need to remove the
  'something' part in order to be able to retrieve that entry and
  serve it to the client. This is a function which does that."
  (cl-ppcre:register-groups-bind (only)
      ("/blog/([A-Za-z0-9\-]+)/?" str)
    only))

(defun retrieve-blog (blog-name)
  "Retrieves the blog-name from the database."
  (first (first (with-db db
                  (clsql:select '|blog-entry| :database db
                                              :where [= [slot-value '|blog-entry| 'blog-url]
                                              blog-name])))))

(defun render-blog (blog)
  "Renders the blog by interpolating its fields into the template."
  (let ((string-stream (with-slots (blog-title blog-post) blog
                         (clob-templates:blog :blog_title blog-title :blog_post blog-post))))
    (get-output-stream-string string-stream)))

(defun blog-entry ()
  "Handler for /blog/something/"
  (let* ((blog-name (extract-blog-title (hunchentoot:request-uri* hunchentoot:*request*)))
         (blog (retrieve-blog blog-name)))
    (render-blog blog)))

(defun blog-list ()
  "Handler for /blog/"
  (let* ((blogs (with-db db
                  (clsql:select '|blog-entry| :database db)))
         (blog-data-list (loop for blog in blogs
                               collect (list :blog_title (slot-value (first blog) 'blog-title)
                                             :date (slot-value (first blog) 'date)
                                             :blog_url (slot-value (first blog) 'blog-url)))))
    (get-output-stream-string (clob-templates:blogmode :blog blog-data-list))))

(defun about ()
  "Handler for /about"
  (let ((blog (render-blog (retrieve-blog "about")))) blog))

(defun index ()
  "Handler for /"
  (get-output-stream-string (clob-templates:index)))

(defun handlers (&rest handlers)
  "Helper method to push N handlers into the dispatch table with a
  nicer syntax than the built-in one."
  (dolist (handler handlers)
    (push handler hunchentoot:*dispatch-table*)))

(handlers
 (hunchentoot:create-regex-dispatcher "^/blog/?$" 'blog-list)
 (hunchentoot:create-regex-dispatcher "^/blog/[A-Za-z0-9\-]+/?$" 'blog-entry)
 (hunchentoot:create-regex-dispatcher "^/about/?$" 'about)
 (hunchentoot:create-regex-dispatcher "^/$" 'index)
 (static-file-handler "/home/xeno/dev/clob/static/"))

(clsql:locally-disable-sql-reader-syntax)
