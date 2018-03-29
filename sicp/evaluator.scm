;;; try to implement the Metacircular evaluator of lisp

;;; the evaluator contains two core function: eval and apply


;;; eval:
;;; 1.eval is used for evaluating expressions. So we need to understand what is the type of expression and then evaluate.

;;; 2.we need to create an abstract of different expression type. Meaning we create getters of different expression type
;;; so that our evaluator does not depend on implementation of different expression type.

;;; 3.currently we use dispatch of control flow. Later after reading following chapters, I need to modify it to be data
;;; directed pattern

;;; 4.expression type:
;;; 1)primitive: self-evaluation, look-up variables, quote
;;; 2)special form: assignment, definition, if, cond, lambda, begin
;;; 3)combinations: application

;;; questions:
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

;;; eval-lambda:
;;; evaluation of lambda creates procedure object. we work on procedure abstract which has parameter, body and environment.
;;; TODO: define "lambda" abstract which contains "lambda-parameters" and "lambda-body"
;;;       define "procedure" abstract which contains 'make-procedure'; 
(define (eval-lambda exp env)
  (make-procedure (lambda-parameters exp)
		  (lambda-body exp)
		  env))

;;; eval-begin:
;;; we assume begin is an object which contains a list of expressions. begin-actions give us the list of expressions
;;; TODO: define "begin" abstract which contains 'begin-actions', "begin-actions" returns a list of expression
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
;;; TODO: define "application" abstract which contains "application-operator" and "application-operands"
(define (eval-application exp env)
  (apply (eval (application-operator exp) env)
	 (eval-list-of-values (application-operator exp) env)
	 env))

(define (eval-list-of-values  exps env)
  (if (null? exps)
      '()
      (cons (eval (car exps) env)
	    (eval-list-of-values (cdr env) env))))
 
