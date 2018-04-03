;;; implement representations of all kinds of expressions by using tagged list

;;;tagged list
(define (tagged-list? exp tag)
  (if (pair? exp)
      (eq? (car exp) tag)
      false))

;;; self-evaluation
(define (self-evaluation? exp)
  (cond ((number? exp) true)
	((string? exp) true)
	(else false)))

;;; variable
(define (variable? exp)
  (symbol? exp))

;;; quote
(define (quote? exp)
  (tagged-list? exp 'quote))

(define (quote-content exp)
  (cadr exp))


