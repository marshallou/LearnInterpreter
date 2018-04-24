;;; analyze: analyze expression to procdure an labmda object. When passed in env, it will produre value of the expression.
(define (analyze exp)
  (cond ((self-evaluation? exp) (analyze-self exp))
	((variable? exp) (analyze-variable exp))
	((quote? exp) (analyze-quote exp))
	((assignment? exp) (analyze-assignment exp))
	((definition? exp) (analyze-definition exp))
	((lambda? exp) (analyze-lambda exp))
	((application? exp) (analyze-application exp))
	(else exp)))

;;; analyze-self: analyze self-evaluating expression
(define (analyze-self exp)
  (lambda (env) exp))


;;; analyze-variable: analyze variable lookup expression and return a lambda object which, when invoked with env, produces variable value.
(define (analyze-variable exp)
  (lambda (env)
    (lookup-variable exp env)))

;;; analyze-quote
(define (analyze-quote exp)
  (lambda (env)
    (quote-content exp)))

;;; analyze-assignment
(define (analyze-assignment exp)
  (let ((var (assignment-variable exp))
	(vproc (analyze (assignment-value exp))))
    (lambda (env)
      (set-variable-value! var (vproc env) env))))

;;; analyze-definition
(define (analyze-definition exp)
    (let ((var (definition-variable exp))
	  (vproc (analyze (definition-value exp))))
      (lambda (env)
	(define-variable! var (vproc env) env))))

;;; analyze-lambda
(define (analyze-lambda exp)
  (let ((params (lambda-parameters exp))
	(bproc (analyze-sequence (lambda-body exp))))
    (lambda (env)
      (make-procedure params bproc env))))

;;; analyze-sequence
(define (analyze-sequence exps)
  (define (execute-procs procs env)
    (cond ((null? (cdr procs))
	   ((car procs) env))
	  (else ((car procs) env)
		(excute-procs (cdr procs env)))))
  (let ((bprocs (map analyze exps)))
    (lambda (env)
      (execute-procs bprocs env))))

;;; analyze-application
(define (analyze-application exp)
  (let ((fproc (analyze (application-operator exp)))
	(aprocs (map analyze (application-operands exp))))
    (lambda (env)
      (execute-application (fproc env)
			   (map (lambda (aproc)
				  (aproc env))
				aprocs)))))
	    

;;; execute-application
(define (execute-application proc args)
  (cond ((primitive-procedure? proc)
	 (apply-primitive-procedure proc args))
	((compound-procedure? proc)
	 ((procedure-body proc)
	  (extend-environment
	   (procedure-parameters proc)
	   args
	   (procedure-environment proc))))
	(else
	 (error
	  "Unknown procedure type -- when executing 'execute-application'"
	  proc))))
