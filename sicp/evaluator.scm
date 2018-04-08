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
	((application? exp) (eval-application exp) env)
	(else (error "Unknown expression type" exp))))

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
