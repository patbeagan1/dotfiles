#!/usr/bin/env -S sbcl --script

;;; Load Quicklisp
(load (merge-pathnames "quicklisp/setup.lisp"
                       (user-homedir-pathname)))

;;; Ensure that the Drakma library is installed
(ql:quickload "drakma")
(ql:quickload "alexandria")

(line-up-first "HELLO"
    string-downcase
    format t)


;;; Function to fetch a URL and measure time taken
(defun fetch-url-with-timing (url)
  "Fetches the URL and returns the content along with the time taken."
  (let ((start-time (get-internal-real-time))
        (content nil))
    (handler-case
        (setq content (drakma:http-request url))
      (error (e)
        (format t "Error fetching ~a: ~a~%" url e)
        (setq content nil)))
    (let ((end-time (get-internal-real-time))
          (seconds (/ (float (- end-time start-time)) internal-time-units-per-second)))
      (values content seconds))))

;;; Function to process a list of URLs
(defun process-urls-from-file (filename)
  "Processes each URL in the file and prints the URL with its runtime."
  (let ((urls (with-open-file (stream filename)
                (loop for line = (read-line stream nil nil)
                      while line
                      collect line)))
        (results '()))
    (dolist (url urls)
      (multiple-value-bind (content time-taken)
          (fetch-url-with-timing url)
        (push (cons url time-taken) results)))
    ;; Print the results
    (format t "~%Results:~%")
    (dolist (result (reverse results))
      (format t "URL: ~a, Time taken: ~2f seconds~%" (car result) (cdr result)))))

;;; Main execution
(defparameter *url-file* "urls.txt") ;; The file containing the URLs

(process-urls-from-file *url-file*)
