


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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; evaluator






;;; eval-if
(define (eval-if exp env)
  (if (true? (eval (if-predicate exp) env))
      (eval (if-consequent exp) env)
      (eval (if-alternative exp) env)))



;;; eval-cond:
(define (eval-cond exp env)
  (eval-if (cond->if exp) env))

;;; eval-begin:
;;; we assume begin is an object which contains a list of expressions. begin-actions give us the list of expressions
;;; Note: the difference between eval-sequence and eval-list-of-values is that eval-sequence returns the last evaluated expression,
;;; while the eval-list-of-values returns a list of evaluated values
(define (eval-begin exp env)
  (eval-sequence (begin-actions exp) env))

(define (eval-sequence exps env)
  (cond ((null? (cdr exps)) (eval (car exps)))
	(else (eval (car exps) env)
	      (eval-sequence (cdr exps) env))))

;;; eval-application:
;;; application means function call. It contains operator (function name) and operands (arguments)
;;; we would like to separate the evaluation process into two step. First evaluating operator and operands. Then evaluating
;;; the triggering process which will be defined by "apply"
(define (eval-application exp env)
  (apply (eval (application-operator exp) env)
	 (eval-list-of-values (application-operands exp) env)
	 env))

(define (eval-list-of-values  exps env)
  (if (null? exps)
      '()
      (cons (eval (car exps) env)
	    (eval-list-of-values (cdr env) env))))


;;; apply
;;; Thinking?: why is procedure body the sequence of expressions. If we look at the lisp procedure definition, the body of procedure
;;; can have multiple expressions. The same for cond
(define (apply procedure arguments)
  (cond ((primitive-procedure? procedure)
	 (apply-primitive-procedure procedure arguments))
	((compound-procedure? procedure)
	 (eval-sequence
	  (procedure-body procedure)
	  (extend-environment
	   (procedure-parameters procedure)
	   arguments
	   (procedure-environment procedure))))
	(else
	 (error
	  "Unknown procedure type -- APPLY" procedure))))


