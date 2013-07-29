(module awful-postgresql (enable-db switch-to-postgresql-database db-result-processor)

(import chicken scheme data-structures)
(use awful postgresql)

(define (enable-db . ignore) ;; backward compatibility: `enable-db' was a parameter
  (switch-to-postgresql-database))

(define db-result-processor
  (make-parameter (lambda (result)
                       (row-map identity result))))

(define (switch-to-postgresql-database)

  (db-enabled? #t)

  (db-connect connect)

  (db-disconnect disconnect)

  (db-inquirer (lambda (q #!key default values)
                 (let ((result
                        (if values
                            (query* (db-connection) q values)
                            (query* (db-connection) q))))
                   (if (zero? (row-count result))
                       default
                       (db-result-processor result)))))

  ;; Deprecated
  (sql-quoter (lambda (data)
                (++ "'" (escape-string (db-connection) (concat data)) "'")))

  (db-make-row-obj (lambda (q)
                     (let ((result (row-alist (query* (db-connection) q))))
                       (lambda (field #!optional default)
                         (or (alist-ref field result)
                             default)))))
  )

) ; end module
