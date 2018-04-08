(load "representations_v1.scm")
(load "evaluator.scm")
(load "evaluator_data_structures.scm")

(define env (list (list (cons 'a 1) (cons 'b 2)) (list (cons 'c 3) (cons 'd 4)) (list (cons 'e 5))))

(define exp '(define (a m) (+ m 3)))

(eval exp env)
