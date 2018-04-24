;;; eval: evaluating expression. The expression types are below:
;;; 1)primitive: self-evaluation, look-up variables, quote
;;; 2)special form: assignment, definition, if, cond, lambda, begin
;;; 3)combinations: application
(define (eval exp env)
  (cond ((self-evaluation? exp) exp)
	((variable? exp) (lookup-variable exp env))
	((quote? exp) (quote-content exp))
	((assignment? exp) (eval-assignment exp env))
	((definition? exp) (eval-definition exp env))
	((lambda? exp) (eval-lambda exp env))
	((if? exp) (eval-if exp env))
	((begin? exp) (eval-begin exp env))
	((cond? exp) (eval-cond exp env))
	((application? exp) (eval-application exp env))
	(else (error "Unknown expression type" exp))))


;;; eval-application:
;;;    eval expression of triggering procedure by applying evaluated arguments
;;;    to the evaluated operator.
(define (eval-application exp env)
  (evaluator-apply (eval (application-operator exp) env)
	 (eval-list-of-values (application-operands exp) env)))

(define (eval-list-of-values  exps env)
  (if (null? exps)
      '()
      (cons (eval (car exps) env)
	    (eval-list-of-values (cdr exps) env))))

;;; apply:
;;;    If the procedure is primitive procedure, load underlying scheme procedure from base environment to execute.
;;;    If the procedure is compound procedure, extract its body to further evaluate.
;;;    Note: procedure body is a list of expressions, rather than a single expression
(define (evaluator-apply procedure arguments)
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

;;; eval-sequence: evaluate a list of expression and return the value of last evaluated expression
(define (eval-sequence exps env)
  (cond ((null? (cdr exps)) (eval (car exps) env))
	(else (eval (car exps) env)
	      (eval-sequence (cdr exps) env))))


;;; assignmeent: change the variable's value specified in assignment expression to the
;;;    new value. Signal error if the variable name does not exist in the envrionment
(define (eval-assignment exp env)
  (set-variable-value! (assignment-variable exp)
			(eval (assignment-value exp) env)
			env)
  'ok)

;;; definition: evaluate definition's value and associate it with definition-variable name
;;;    in current environment (first frame of the environment). If the definition-variable
;;;    name already exists, set it to new value.
(define (eval-definition exp env)
  (define-variable! (definition-variable exp)
    (eval (definition-value exp) env)
    env)
  'ok)

;;; eval-lambda:
;;; evaluation of lambda creates procedure object. we work on procedure abstract which has parameter, body and environment.
;;;       define "procedure" abstract which contains 'make-procedure'; 
(define (eval-lambda exp env)
  (make-procedure (lambda-parameters exp)
		  (lambda-body exp)
		  env))

;;; eval-if
(define (eval-if exp env)
  (if (eval (if-predicate exp) env)
      (eval (if-consequent exp) env)
      (eval (if-alternative exp) env)))

;;; eval-cond:
(define (eval-cond exp env)
  (eval-if (cond->if exp) env))

;;; eval-begin:
;;; we assume begin is an object which contains a list of expressions. begin-actions give us the list of expressions
(define (eval-begin exp env)
  (eval-sequence (begin-actions exp) env))
