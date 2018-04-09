;;; cond
(define (cond? exp)
  (tagged-list? exp 'cond))

(define (cond-clauses exp)
  (cdr cond))

(define (cond->if exp)
  (cond->if-iter (cond-clauses exp)))

(define (clause-predicate clause)
  (car clause))

(define (clause-value clause)
  (sequence->exp (cdr clause)))

(define (else-clause? clause)
  (eq? (car clause) 'else))

(define (cond-if-iter clauses)
  (let ((first-clause (car clauses))
	(rest-clauses (cdr clauses)))
    (let ((alternative
	   (cond ((null? rest-clauses) 'false)
		 ((else-clause? (car rest-clause)) (clause-value rest-clauses))
		 (else (cond-if-iter rest-clauses)))))
      (make-if (clause-predicate first-clause)
	       (clause-value first-clause)
	       alternative))))

(define (sequence->exp exp)
  (cond ((null? exp) exp)
	((null? (cdr exp)) (car exp))
	(else (cons 'begin exp))))












