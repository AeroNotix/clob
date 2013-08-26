(in-package :clob-templates)

(defmacro deftemplate (name template-name)
  `(defun ,name (&rest data)
     (let* ((template-directory (asdf:component-pathname
				 (asdf:find-component (asdf:find-system :clob) "templates")))
	    (path (format nil "~a" (merge-pathnames template-directory ,template-name)))
	    (string-stream (make-string-output-stream)))
       (apply #'djula:render-template* path string-stream :STATIC_URL "/static/" data)
       string-stream)))

(deftemplate blog "blog.html")
(deftemplate not-found "404.html")
(deftemplate blogmode "blog-mode.html")
(deftemplate index "base.html")
