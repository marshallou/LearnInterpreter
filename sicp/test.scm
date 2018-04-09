(load "representations_v1.scm")
(load "evaluator_data_structures.scm")
(load "evaluator.scm")

(define base-env load-base-env-with-primitive-procedure)

(define env (list (list (cons 'a 1) (cons 'b 2))
		  (list (cons 'c 3) (cons 'd 4))
		  (list (cons 'e 5))
		  (car base-env)))

(define exp-define '(define (run m) (if (> m 3) (+ m 10) (+ m 1))))

(define exp-run '(run d))

(eval exp-define env)
(eval exp-run env)
