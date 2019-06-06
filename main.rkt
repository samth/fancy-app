#lang racket/base

(require (for-syntax racket/base))

(define-for-syntax (make-tooltip stx id msg)
  (define pos (syntax-position id))
  (define span (syntax-span id))
  (syntax-property
   stx
   'mouse-over-tooltips
   (and pos span (vector id (sub1 pos) (sub1 (+ pos span)) msg))))

(define-syntax (-app stx)
  (syntax-case stx ()
    [(app arg ...)
     (let loop ([args (syntax->list #'(arg ...))] [ids null] [result null])
       (cond 
         [(and (null? args) (null? ids))
          (datum->syntax #'here `(#%app ,@(reverse result)) stx stx)]
         [(null? args)
          (make-tooltip
           (datum->syntax #'here
                          `(lambda ,(reverse ids)
                             ,(datum->syntax #'here `(#%app ,@(reverse result)) stx stx))
                          stx stx)
           stx
           "this application is automatically a function using _")]
         [(and (identifier? (car args)) (free-identifier=? (car args) #'_))
          (let* ([_-id (car args)]
                 [id (car (generate-temporaries '(_)))]
                 [tmp
                  (make-tooltip
                   (syntax-track-origin id _-id #'_)
                   _-id
                   "_ is the parameter to the anonymous function")])
            (loop (cdr args) (cons tmp ids) (cons tmp result)))]
         [else
          (loop (cdr args) ids (cons (car args) result))]))]))

(provide (rename-out [-app #%app]))

(module+ test
  (require rackunit)
  (define (f . xs) xs)
  (check-equal? (-app (-app f _ 1 _ _ 4) 0 2 3) '(0 1 2 3 4))
  (check-equal? (-app list 1 2 3) '(1 2 3))
  (define (g x #:y y) (- x y))
  (check-equal? (-app (-app g #:y 10 _) 100) 90)
  (check-equal? (-app (-app g _ #:y 10) 100) 90))
