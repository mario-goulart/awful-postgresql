(module awful-postgresql (enable-db switch-to-postgresql-database db-result-processor)

(import scheme)
(cond-expand
  (chicken-4
   (import chicken data-structures)
   (use awful postgresql))
  (chicken-5
   (import (chicken base))
   (import awful postgresql))
  (else
   (error "Unsupported CHICKEN version.")))

(define (enable-db . ignore) ;; backward compatibility: `enable-db' was a parameter
  (switch-to-postgresql-database))

(define db-result-processor
  (make-parameter (lambda (result)
                       (row-map identity result))))

(define (switch-to-postgresql-database)

  (db-enabled? #t)

  (db-connect connect)

  (db-disconnect disconnect)

  (db-inquirer (lambda (q #!key (default '()) values)
                 (let ((result
                        (if values
                            (query* (db-connection)
                                    ((db-query-transformer) q)
                                    values)
                            (query* (db-connection)
                                    ((db-query-transformer) q)))))
                   (if (zero? (row-count result))
                       default
                       ((db-result-processor) result)))))

  (db-make-row-obj (lambda (q)
                     (let ((result (row-alist (query* (db-connection)
                                                      ((db-query-transformer) q)))))
                       (lambda (field #!optional default)
                         (or (alist-ref field result)
                             default)))))
  )

) ; end module
