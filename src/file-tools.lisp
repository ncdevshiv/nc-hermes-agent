(defpackage :nc-hermes-agent.file-tools
  (:use :cl :nc-hermes-agent.tools :nc-hermes-agent.skills)
  (:export :init-file-tools))
(in-package :nc-hermes-agent.file-tools)

(defun tool-read-file (args)
  (let ((filepath (gethash "filepath" args)))
    (if (and filepath (probe-file filepath))
        (alexandria:read-file-into-string filepath)
        (format nil "Error: File ~A not found or missing argument." filepath))))

(defun tool-write-file (args)
  (let ((filepath (gethash "filepath" args))
        (content (gethash "content" args)))
    (if (and filepath content)
        (progn
          (with-open-file (stream filepath
                                  :direction :output
                                  :if-exists :supersede
                                  :if-does-not-exist :create)
            (write-string content stream))
          (format nil "Successfully wrote to ~A." filepath))
        "Error: Missing 'filepath' or 'content' argument.")))

(defun tool-list-files (args)
  (let ((directory (gethash "directory" args "./")))
    (if (probe-file directory)
        (let ((files (uiop:directory-files directory)))
          (format nil "Files in ~A:~%~{~A~%~}" directory (mapcar #'file-namestring files)))
        (format nil "Error: Directory ~A not found." directory))))

(defun init-file-tools ()
  "Registers foundational file system tools."
  (let ((schema-read (make-hash-table :test 'equal))
        (props-read (make-hash-table :test 'equal))
        (prop-filepath (make-hash-table :test 'equal)))
    (setf (gethash "type" prop-filepath) "string")
    (setf (gethash "description" prop-filepath) "The path of the file to read.")
    (setf (gethash "filepath" props-read) prop-filepath)
    (setf (gethash "type" schema-read) "object")
    (setf (gethash "properties" schema-read) props-read)
    (setf (gethash "required" schema-read) '("filepath"))
    (register-tool "read_file" "Reads the content of a file." schema-read #'tool-read-file))

  (let ((schema-write (make-hash-table :test 'equal))
        (props-write (make-hash-table :test 'equal))
        (prop-filepath (make-hash-table :test 'equal))
        (prop-content (make-hash-table :test 'equal)))
    (setf (gethash "type" prop-filepath) "string")
    (setf (gethash "description" prop-filepath) "The path of the file to write.")
    (setf (gethash "type" prop-content) "string")
    (setf (gethash "description" prop-content) "The content to write.")
    (setf (gethash "filepath" props-write) prop-filepath)
    (setf (gethash "content" props-write) prop-content)
    (setf (gethash "type" schema-write) "object")
    (setf (gethash "properties" schema-write) props-write)
    (setf (gethash "required" schema-write) '("filepath" "content"))
    (register-tool "write_file" "Writes content to a file." schema-write #'tool-write-file))

  (let ((schema-list (make-hash-table :test 'equal))
        (props-list (make-hash-table :test 'equal))
        (prop-directory (make-hash-table :test 'equal)))
    (setf (gethash "type" prop-directory) "string")
    (setf (gethash "description" prop-directory) "The directory to list files from (defaults to './').")
    (setf (gethash "directory" props-list) prop-directory)
    (setf (gethash "type" schema-list) "object")
    (setf (gethash "properties" schema-list) props-list)
    (register-tool "list_files" "Lists files in a directory." schema-list #'tool-list-files))

  (format t "File tools initialized.~%"))

(register-skill "file-tools" #'init-file-tools)
