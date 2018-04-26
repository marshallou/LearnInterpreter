;;; evaluate expression with initial success and fail passed in.
;;; Note the difference between amb analyzer and normal analyzer is that amb analyzer produce lambda which takes three arguments: env, success and fail.

;;; The execution phase is entirely non-determined. It can call success or fail based on run time value generated.
(define (ambeval exp env success fail)
  ((analyze exp) env success fail))


;;; analyze: analyze expression to procdure an labmda object. When passed in env, success and fail, it will produre value of the expression.
(define (analyze exp)
  (cond ((self-evaluation? exp) (analyze-self exp))
	((variable? exp) (analyze-variable exp))
	((quote? exp) (analyze-quote exp))
	((assignment? exp) (analyze-assignment exp))
	((definition? exp) (analyze-definition exp))
	((lambda? exp) (analyze-lambda exp))
	((if? exp) (analyze-if exp))
	((amb? exp) (analyze-amb exp))
	((application? exp) (analyze-application exp))
	(else error "Non-supported exp to analyze")))


;;; analyze-self: predestined to be success.
(define (analyze-self exp)
  (lambda (env success fail)
      (success exp fail)))


;;; analyze-variable:
(define (analyze-variable exp)
  (lambda (env success fail)
    (let ((var (lookup-variable exp env)))
      (success var fail))))


;;; analyze-quote
(define (analyze-quote exp)
  (lambda (env success fail)
    (success (quote-content exp) fail)))


;;; analyze-assignment
(define (analyze-assignment exp)
  (let ((var (assignment-variable exp))
	(vproc (analyze (assignment-value exp))))
    (lambda (env success fail)
      (vproc
       env
       (lambda (new-val fail2)
	 (let ((old-val (lookup-variable var env)))
	   (set-variable-value! var new-val env)
	   (success 'ok
		   (lambda ()
		     (set-variable-value! var old-val env)
		     (fail2)))))
       fail))))


;;; analyze-definition
(define (analyze-definition exp)
  (let ((var (definition-variable exp))
	(vproc (analyze (definition-value exp))))
    (lambda (env success fail)
      (vproc
       env
       (lambda (val fail2)
	 (define-variable! var val env)
	 (success 'ok fail2))
       fail))))


;;; analyze-lambda
(define (analyze-lambda exp)
  (let ((params (lambda-parameters exp))
	(bproc (analyze-sequence (lambda-body exp))))
    (lambda (env success fail)
      (success (make-procedure params bproc env)
	       fail))))


;;; analyze-sequence
;;;  analyze phase: analyze all exps in the sequence
;;;  execution phase: execute-procs will execute analyzed sequence 1 by 1. The success will not change along the chain, while fail is updated each time by exps.
(define (analyze-sequence exps)
  (define (execute-procs procs env success fail)
    (cond ((null? (cdr procs))
	   ((car procs) env success fail))
	  (else ((car procs)
		 env
		 (lambda (val fail2)
		   (execute-procs (cdr procs)
				  env
				  success
				  fail2))
		 fail))))
  (let ((bprocs (map analyze exps)))
    (lambda (env success fail)
      (execute-procs bprocs env success fail))))


;;; analyze-application
;;;   3 steps:
;;;    execute fproc to fetch the procedure.
;;;    if success, execute get-args to fetch all args
;;;    if success, trigger procedure with args
(define (analyze-application exp)
  (let ((fproc (analyze (application-operator exp)))
	(aprocs (map analyze (application-operands exp))))
    (lambda (env success fail)
      (fproc
       env
       (lambda (proc fail2)
	 (get-args aprocs
		   env
		   (lambda (args fail3)
		     (execute-application proc
					  args
					  success
					  fail3))
		   fail2))
       fail))))



;;; get-args
;;;    invariant: get-args will call its 'success' parameter with all its 'apocs' parameter evaluated.
;;;    base case: when aprocs equal null, 'success' will be called with empty list.
;;;    induction: when we eval first of aprocs, if success, it will call "get-args" with rest of aprocs. Based on invariant, "get-args" will return rest of evaluated args. We cons "arg" with rest of "args" and call 'success' with it. Thus, the invariant keeps
;;;    result: original 'success' is called with all args evaluated.
(define (get-args aprocs env success fail)
  (if (null? aprocs) (success '() fail)
      ((car aprocs)
       env
       (lambda (arg fail2)
	 (get-args (cdr aprocs)
		   env
		   (lambda (args fail3)
		     (success (cons arg args)
			      fail3))
		   fail2))
       fail)))


;;; execute-application
(define (execute-application proc args success fail)
  (cond ((primitive-procedure? proc)
	 (success (apply-primitive-procedure proc args)
		  fail))
	((compound-procedure? proc)
	 ((procedure-body proc)
	  (extend-environment
	   (procedure-parameters proc)
	   args
	   (procedure-environment proc))
	  success
	  fail))
	(else
	 (error
	  "Unknown procedure type -- when executing 'execute-application'"
	  proc))))


;;; analyze-if:
;;;  check README.md for detailed description
(define (analyze-if exp)
  (let ((pproc (analyze (if-predicate exp)))
	(cproc (analyze (if-consequent exp)))
	(aproc (analyze (if-alternative exp))))
    (lambda (env succeed fail)
      (pproc env
	     (lambda (pred-value fail2)
	       (if pred-value
		   (cproc env succeed fail2)
		   (aproc env succeed fail2)))
	     fail))))

;;; analyze-amb
(define (analyze-amb exp)
  (let ((cprocs (map analyze (amb-choices exp))))
    (lambda (env succeed fail)
      (define (try-next choices)
	(if (null? choices)
	    (fail)
	    ((car choices) env
	     succeed
	     (lambda ()
	       (try-next (cdr choices))))))
      (try-next cprocs))))
