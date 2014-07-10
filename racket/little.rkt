#lang racket
(define atom? 
  (lambda (x)
    (and (not (pair? x)) (not (null? x)))))

(atom? (quote ()))

(car '(a b c))
(cdr '((a b c) x y z))
(cdr '(hamburger))
(cons 'peanut '(butter and jelly))
(cons '(peanut butter) '(and jelly))
(cons 'a '(b))
(cons 'a 'b)
(car (cons 'a 'b))
(cdr (cons 'a 'b))

(null? '())
(null? '(a))
(null? 'a)

(eq? 'Abc 'Abc)
(eq? 'Abc 'abc)
(eq? '(Harry) '(Harry))

(define lat?
  (lambda (l)
    (cond
      ((null? l) #t)
      ((atom? (car l)) (lat? (cdr l)))
      (else #f))))

(lat? '(a b c))
(lat? '((a) b c))

(define member?
  (lambda (a lat)
    (cond
      ((null? lat) #f)
      ((eq? (car lat) a) #t)
      (else (member? a (cdr lat))))))

(member? 'a '(a b))
