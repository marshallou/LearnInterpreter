(load "representations_v1.scm")
(load "evaluator_data_structures.scm")
(load "analyzer.scm")

(define base-env load-base-env-with-primitive-procedure)

(define input-prompt ";;; Amb-Eval input:")

(define output-prompt ";;; Amb-Eval value:")

(define (prompt-for-input string)
  (newline) (newline) (display string) (newline))

(define (announce-output string)
  (newline) (display string) (newline))

(define (user-print object)
  (if (compound-procedure? object)
     (display (list 'compound-procedure
		 (procedure-parameters object)
		 (procedure-body object)
		 '<procedure-env>))
     (display object)))

(define (driver-loop)
  (define (internal-loop try-again)
    (prompt-for-input input-prompt)
    (let ((input (read)))
      (if (eq? input 'try-again)
	  (try-again)
	  (begin
	    (newline)
	    (display ";;; Starting a new problem ")
	    (ambeval input
		     base-env
		     ;; ambeval success
		     (lambda (val next-alternative)
		       (announce-output output-prompt)
		       (user-print val)
		       (internal-loop next-alternative))
		     ;; ambeval failure
		     (lambda ()
		       (announce-output
			";;; There are no more values of")
		       (user-print input)
		       (driver-loop)))))))
  (internal-loop
   (lambda ()
     (newline)
     (display ";;; There is no current problem")
     (driver-loop))))

(driver-loop)
