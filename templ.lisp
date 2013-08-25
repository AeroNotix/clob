(in-package :clob-templates)

(defmacro deftemplate (name template-name)
  `(defun ,name (&rest data)
     (let* ((template-directory (asdf:component-pathname
				 (asdf:find-component (asdf:find-system :clob) "templates")))
	    (tmpl (djula:compile-template
		   djula:*current-compiler*
		   (format nil "~a" (merge-pathnames template-directory ,template-name)))))
       (funcall tmpl data))))

(deftemplate blog "blog.html")
(deftemplate not-found "404.html")
(deftemplate blog-mode "blog-mode.html")
