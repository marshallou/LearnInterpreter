(load "representations_v1.scm")
(load "evaluator_data_structures.scm")
(load "analyzer.scm")

(define base-env load-base-env-with-primitive-procedure)

(define env (list (list (cons 'a 1) (cons 'b 2))
		  (list (cons 'c 3) (cons 'd 4))
		  (list (cons 'e 5))
		  (car base-env)))

(define (success val fail)
  val)

(define (fail)
  (display "failed!!!"))

(define exp '(define (changeb x) (if (> x 5) (set! b x) (set! b 1))))

(ambeval exp env success fail)

(define exp3 '(changeb 10))

(ambeval exp3 env success fail)

(define exp2 'b)

(ambeval exp2 env success fail)


