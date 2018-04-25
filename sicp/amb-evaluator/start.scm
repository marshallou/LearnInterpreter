(load "representations_v1.scm")
(load "evaluator_data_structures.scm")
(load "analyzer.scm")

(define base-env load-base-env-with-primitive-procedure)

;;; io-message: print instruction message for user, like
;;;    prompt input, output
(define (instruction-message str)
  (newline)
  (newline)
  (display str)
  (newline))

(define (input-prompt)
  (instruction-message ";;; Eval input: "))

(define (output-message)
  (instruction-message ";;; Eval output: "))

;;; driver-loop: start evaluator
(define (driver-loop)
  (input-prompt)
  (let ((input (read)))
    (let ((output (eval input base-env)))
      (output-message)
      (output-content output)))
  (driver-loop))

;;; output-content:
;;;    for procedures, it contains its environment which may be a very long list or contain cycles. output-content prints only parameters and body.
(define (output-content output)
  (if (compound-procedure? output)
      (display (list 'compound-procedure
		     (procedure-parameters output)
		     (procedure-body output)
		     '<procedure-env>))
      (display output)))

;;; start
(driver-loop)
