;;; implement the Metacircular evaluator of lisp

;;; the evaluator contains two core function: eval and apply


;;; eval :
;;; 1.eval is used for evaluating expressions. So we need to understand what is the type of expression and then evaluate.

;;; 2.we need to create an abstract of different expression type. Meaning we create getters of different expression type
;;; so that our evaluator does not depend on implementation of different expression type.

;;; 3.currently we use dispatch of control flow. Later after reading following chapters, I need to modify it to be data
;;; directed pattern

;;; 4.expression type:
;;; 1)primitive: self-evaluation, look-up variables, quote
;;; 2)special form: assignment, definition, if, cond, lambda, begin
;;; 3)combinations: application


(define (eval exp env)
  (cond ((self-evaluation? exp) exp)
	((variable? exp) (look-up-variable exp))
	((quote? exp) (quote-content exp))
	((assignment? exp) (eval-assignment exp env))
	((definition? exp) (eval-definition exp env))
	((if? exp) (eval-if exp env))
	((lambda? exp) (eval-lambda exp env))
	((begin? exp) (eval-begin exp env))
	((cond? exp) (eval-cond exp env))
	((application? exp) (eval-application exp) env)
	(else (error "Unknown expression type" exp))))

;;; define and assignment
;;; the difference between set-variable-value! and define-variable! is that "set" will search all the way to base environment
;;; and signal error, while "define" adds the value into the first frame of environment
(define (eval-assignment exp env)
  (set-variable-value! (assignment-variable exp)
			(eval (assignment-value exp) env)
			env)
  'ok)

(define (eval-definition exp env)
  (define-variable! (definition-variable exp)
    (eval (definition-value exp) env)
    env)
  'ok)

;;; eval-if
(define (eval-if exp env)
  (if (true? (eval (if-predicate exp) env))
      (eval (if-consequent exp) env)
      (eval (if-alternative exp) env)))

;;; eval-lambda:
;;; evaluation of lambda creates procedure object. we work on procedure abstract which has parameter, body and environment.
;;;       define "procedure" abstract which contains 'make-procedure'; 
(define (eval-lambda exp env)
  (make-procedure (lambda-parameters exp)
		  (lambda-body exp)
		  env))

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


