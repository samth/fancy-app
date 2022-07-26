#lang racket/base

(provide (rename-out [@#%app #%app]))
(require syntax/parse/define
         (for-syntax racket/base
                     racket/syntax
                     syntax/stx))

(begin-for-syntax
  (define (make-tooltip stx id msg)
    (define pos (syntax-position id))
    (define span (syntax-span id))
    (syntax-property
     stx
     'mouse-over-tooltips
     (and pos span (vector id (sub1 pos) (sub1 (+ pos span)) msg))))
  (define (gen-id _-id)
    (make-tooltip (syntax-track-origin (generate-temporary '_) _-id #'_) _-id
                  "_ is the parameter to the anonymous function"))
  (define-syntax-class arg
    (pattern (~and id* (~literal _)) #:attr id (gen-id #'id*))
    (pattern _ #:attr id #f)))

(define-syntax-parser @#%app
  [(_ a:arg ...+)
   #:when (not (stx-null? #'((~? a.id) ...)))
   #:with lambda-body-expr (syntax/loc this-syntax (#%app (~? a.id a) ...))
   (make-tooltip #'(λ ((~@ (~? a.id) ...)) lambda-body-expr)
                 this-syntax
                 "this application is automatically a function using _")]
  [(_ f:expr e ...) (syntax/loc this-syntax (#%app f e ...))])

(module+ test
  (require rackunit)
  (define (f . xs) xs)
  (check-equal? (@#%app (@#%app f _ 1 _ _ 4) 0 2 3) '(0 1 2 3 4))
  (check-equal? (@#%app (@#%app _ _ 1 _ _ 4) f 0 2 3) '(0 1 2 3 4))
  (check-equal? (@#%app list 1 2 3) '(1 2 3))
  (define (g x #:y y) (- x y))
  (check-equal? (@#%app (@#%app g #:y 10 _) 100) 90)
  (check-equal? (@#%app (@#%app g _ #:y 10) 100) 90)
  (define (h) 1)
  (check-equal? (@#%app h) 1)
  (check-equal? ((@#%app _) h) 1))
