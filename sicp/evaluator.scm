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
;;; 3)combinations: procedure

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
	((procedure? exp) (eval-procedure exp) env)
	(else (error "Unknown expression type" exp))))
