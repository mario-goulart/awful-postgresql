(module awful-postgresql (enable-db)

(import chicken scheme data-structures)
(use awful postgresql)

(define (enable-db . ignore) ;; backward compatibility: `enable-db' was a parameter

  (db-enabled? #t)

  (db-connect connect)

  (db-disconnect disconnect)

  (db-inquirer (lambda (q #!key default)
                 (let ((result (query* (db-connection) q)))
                   (if (zero? (row-count result))
                       default
                       (row-map identity result)))))

  (sql-quoter (lambda (data)
                (++ "'" (escape-string (db-connection) (concat data)) "'")))

  (db-make-row-obj (lambda (q)
                     (let ((result (row-alist (query* (db-connection) q))))
                       (lambda (field #!optional default)
                         (or (alist-ref field result)
                             default)))))
  )

) ; end module
