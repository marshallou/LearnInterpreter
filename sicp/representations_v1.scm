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

;;; definition has two forms:
;;;    (define a b)
;;;    (define (procedure_name a) (body)) is syntax sugar of (define procedure_name (lambda (a) body))
(define (definition? exp)
  (tagged-list? exp 'define))

;;; variable-definition?
;;;    definition has two forms, variable-definition and procedure-definition. This method tells
;;;    whether the exp is variable-definition or not
(define (variable-definition? exp)
  (symbol? (cadr exp)))

;;; definition-variable:
;;;    returns the variable name of expression
(define (definition-variable exp)
  (cond ((variable-definition? exp) (cadr exp))
	(else (caadr exp))))

;;; definition-value:
;;;    returns the procedure object if the exp is procedure definition, otherwise returns the variable value
(define (definition-value exp)
  (cond ((variable-definition? exp) (caddr exp))
	(else (make-lambda (cdadr exp)
			   (cddr exp)))))

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

;;; application?
;;;    application is the expression of triggering procedure. We identify expression by exclude all those special operators like if, cond, begin
(define (application? exp)
  (pair? exp))

(define (application-operator exp)
  (car exp))

(define (application-operands exp)
  (cdr exp))

;;; if
;;; sample: (if (> a 1) 2 3)
(define (if? exp)
  (tagged-list? exp 'if))

(define (if-predicate exp)
  (cadr exp))

(define (if-consequent exp)
  (caddr exp))

(define (if-alternative exp)
  (if (null? (cadddr exp))
      false
      (cadddr exp)))

(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

;;; begin
(define (begin? exp)
  (tagged-list? exp 'begin))

(define (begin-actions exp)
  (cdr exp))
