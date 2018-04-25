(load "representations_v1.scm")
(load "evaluator_data_structures.scm")
(load "analyzer.scm")

(define base-env load-base-env-with-primitive-procedure)

(define env (list (list (cons 'a 1) (cons 'b 2))
		  (list (cons 'c 3) (cons 'd 4))
		  (list (cons 'e 5))
		  (car base-env)))

(define exp '(define (add x) (if (> x 10) (+ x 10) (+ x 20))))
((analyze exp) env)

(define exp2 '(add a))
((analyze exp2) env)

