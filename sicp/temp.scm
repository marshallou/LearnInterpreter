

(define (cond-clauses exp)
  (cdr exp)

(define (clause-predicate clause)
  (car clause))

(define (clause-value clause)
  (sequence->exp (cdr clause)))


;;; sequence->exp:
;;;    convert a list of expression to a single expression.
;;;    if the given list contains only one expression, returns the expression.
;;;    If the given expression has more than one expression, convert them into "begin" expression
(define (sequence->exp exp)
  (cond ((null? exp) exp)
	((null? (cdr exp)) (car exp))
	(else (cons 'begin exp))))




(define (else-clause? clause)
  (eq? (car clause) 'else))

(define (cond->if exp)
  (cond-if-iter (cond-clauses exp)))

(define (cond-if-iter clauses)
  (let ((first-clause (car clauses))
	(rest-clauses (cdr clauses)))
    (let ((alternative
	   (cond ((null? rest-clauses) false)
		 ((else-clause? (car rest-clause)) (clause-value rest-clauses))
		 (else (cond-if-iter rest-clauses)))))
      (make-if (clause-predicate first-clause)
	       (clause-value first-clause)
	       alternative))))










