;;; representing of all kinds of expressions by using tagged list

;;;tagged list
(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      false))

;;; self-evaluation
(define (self-evaluation? exp)
  (cond ((number? exp) true)
	((string? exp) true)
	(else false)))

;;; variable
(define (variable? exp)
  (symbol? exp))

;;; quote
(define (quote? exp)
  (tagged-list? exp 'quote))

(define (quote-content exp)
  (cadr exp))


;;; assignment: (set! a b)
(define (assignment? exp)
  (tagged-list? exp 'set!))

(define (assignment-variable exp)
  (cadr exp))

(define (assignment-value exp)
  (caddr exp))

;;; definition:
;;; sample:
;;;  (define a b)
;;;  (define (function_name a)
;;;    (body))
;;;  (define function_name
;;;    (lambda (a) body))
(define (definition? exp)
  (tagged-list? exp 'define))

(define (variable-definiton? exp)
  (symbol? (cadr exp)))

(define (function-definition exp)
  (not (variable-definition exp)))

(define (definition-variable exp)
  (cond ((variable-definition? exp) (cadr exp))
	((function-definition? exp) (caadr exp))
	(else (error "Not a definition type" exp))))

(define (definition-value exp)
  (cond ((variable-definition? exp) (caddr exp))
	((function-definition? exp)
	 (make-lambda (cdadr exp)
		      (cddr exp)))
	(else (error "Not a defnition type" exp))))

;;; lambda
;;; (lambda (a) (+ a 1))
(define (lambda? exp)
  (tagged-list? exp 'lambda))

(define (lambda-parameters exp)
  (cadr exp))

(define (lambda-body exp)
  (cddr exp))

(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

;;; if
;;; sample: (if (> a 1) 2 3)
(define (if? exp)
  (tagged-list? exp 'if))

(define (if-predicate exp)
  (cadr exp))

(define (if-consequent exp)
  (caddr exp))

(define (if-alternative exp)
  (if (null? cadddr exp)
      'false
      (cadddr exp)))

(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

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

;;; begin
(define (begin? exp)
  (tagged-list? exp 'begin))

(define (begin-actions exp)
  (cdr exp))


;;; application
;;; sample: (+ a 2)
(define (application? exp)
  (pair exp))

(define (application-operator exp)
  (car exp))

(define (application-operands exp)
  (cdr exp))
