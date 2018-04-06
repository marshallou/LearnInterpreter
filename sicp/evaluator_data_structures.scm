;;; This file contain data structures used by evaluator.
;;; Two data structures are: environment and procedure:

;;; environment:
;;;  abstractions: extend-environment, set-variable-value!, define-variable!

;;; procedure:
;;;  abstactions: make-procedure, procedure-parameters, procedure-environment,
;;;    procedure-body, primitive-procedure?, apply-primitive-procedure, compound-procedure?

;;; procedure
(define (make-procedure parameters body env)
  (list 'procedure parameters body env))

(define (procedure-parameters exp)
  (cadr exp))

(define (procedure-body exp)
  (caddr exp))

(define (procedure-environment exp)
  (cadddr exp))

;;; TODO: tagged-list? has not been defined here. load representations_v1.scm
(define (compound-procedure? exp)
  (tagged-list? exp 'procedure))

;;; TODO: implement apply-primitive-procedure


;;; environment
;;;   pair: (cons key value), key is the variable name, while value is the variable value
;;;   frame: a list of pairs
;;;   environment: a list of frames.
(define (environment-variables env)
  (car env))

(define (enclosing-environment env)
  (cdr env))


;;; lookup-pair-and-operate:
;;;    description: 
;;;        1)scan variable in the env to find the pair whose key equals variable.
;;;        2)execute operation by passing pair found at 1) as parameter and return the operation result
;;;        3)signal error if not found the pair
;;;    variable: variable wants to find in environment
;;;    environment:
;;;    operation: the operation wants to perform on the key/value pair found
(define (lookup-pair-and-operate variable environment operation)
  (define (look-up var frame env op)
    (cond ((and (null? frame) (null? env)) (error "variable does not exist in environment"))
	  ((null? frame) (look-up var (car env) (cdr env) op))
	  ((not (eq? (car (car frame)) var)) (look-up var (cdr frame) env op))
	  (else (op (car frame)))))
  (cond ((null? environment) (error "environment is null"))
	(else (look-up variable (car environment) (cdr environment) operation))))

;;; lookup-variable:
;;;     description: scan var in a list of pairs in current environment.
;;;         return value of the pair if variable found, otherwise signal error
;;;     var: variable name
;;;     env:
(define (lookup-variable var env)
  (lookup-pair-and-operate var env cdr))

;;; set-variable-value:
;;;    description: scan variable in the environment. set variable to the given value.
;;;        Signal error if the value is not found
;;;    var:
;;;    val:
;;;    env:
(define (set-variable-value! var val env)
  (lookup-pair-and-operate var
			   env
			   (lambda (pair) (set-cdr! pair val))))

;;; define-variable!
;;;    description: add the var/val pair into first frame of environment. If the variable exists,
;;;      change the value to val.
;;;    var: variable name
;;;    val: value
;;;    env: the environment
(define (define-variable! var val env)
  (define first-frame (car env))
  (define new-pair (cons var val))
  (define (scan pairs)
    (cond ((null? pairs) (add-pair new-pair env))
	  ((eq? (car (car pairs)) var) (set-cdr! (car pairs) val))
	  (else (scan (cdr pairs)))))
  (if (null? env)
      (list (list (cons var val)))
      (scan (car env))))

;;; add-pair:
;;;   add pair into the first frame of the environment
;;;   pair: the varialbe wants to add into environment
;;;   env: the environmment
(define (add-pair pair env)
  (let ((new-frame (cons pair (car env))))
    (set-car! env new-frame)))

;;; test define-variable!
;;; env: ( ((a, 1) (b, 2)), ((c, 3), (d, 4)), ((e, 5)) )
;;; set c 5
(define env (list (list (cons 'a 5) (cons 'b 2)) (list (cons 'c 3) (cons 'd 4)) (list (cons 'e 5))))
(set-variable-value! 'c 5 env)
env
