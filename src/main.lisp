;;; -*- mode: lisp -*-

(in-package #:woo-drakma-memleak)

(defvar *server* nil)

(defvar *app* (make-instance 'ningle:app))

(defun time-formatter-fn ()
  (multiple-value-bind (second minute hour date month year)
      (get-decoded-time)
    (format nil "~2,'0d.~2,'0d.~4,'0d ~2,'0d:~2,'0d:~2,'0d" date month year hour minute second)))

(defun log-formatter-fn (format-str level-str package-keyword args)
  (declare (ignore package-keyword))
  (apply 'format
         (append (list
                  nil
                  (concatenate 'string "[~a] ~a<~a> - " format-str "~%"))
                 (list
                  (time-formatter-fn)
                  (make-string (- 6 (length level-str))
                               :initial-element #\space)
                  level-str)
                 args)))

(defun json-result (result)
  (values "application/json; charset=utf-8"
          (to-json result)))

(defun api-response (code result result-fn)
  (bind (((:values content-type result-string) (funcall result-fn result)))
    `(,code (:content-type ,content-type) (,result-string))))

(defun test-mem-leak ()
  (with-timeout (1)
    (drakma:http-request "http://8.8.8.8")))

(defun process-command (command)
  (match command
    ("test-mem-leak" (test-mem-leak))
    (otherwise (error "Command not found"))))

(setf (ningle:route *app* "/api/:command")
      (lambda (params)
        (bind ((result-fn #'json-result)
               (command (cdr (assoc :command params))))
          (vom:info "API command received: ~a" command)
          (handler-case
              (bind ((result (process-command command)))
                (vom:info "API command result: ~a" result)
                (setf (getf result :status) :ok)
                (api-response 200 result result-fn))
            (serious-condition (c)
              (bind ((errresult `(:status :error :text ,(format nil "~a" c))))
                (vom:info "API error occured: ~a" c)
                (api-response 500 errresult result-fn)))))))

(defun stop-server ()
  (if *server*
      (progn
        (clack:stop *server*)
        (setf *server* nil))
      :no-running-server-found))

(defun start-server ()
  (vom:info "Starting server")
  (if *server*
      :running-server-found
      (bind ((app (lack:builder
                   :backtrace
                   *app*)))
        (clack:clackup app
                       :server :woo
                       :address "0.0.0.0"
                       :port 3000
                       :use-default-middlewares nil
                       :use-thread nil
                       :debug nil))))

(defun main ()
  (setf *print-pretty* nil)
  (setf vom:*log-formatter* #'log-formatter-fn)
  (vom:config t :info)
  (handler-case
      (start-server)
    (error (e)
      (vom:error "~a" e))))

(defun main-entry ()
  (main))
