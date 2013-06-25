#lang racket/base

(require (for-syntax racket/base))

(define-syntax (-app stx)
  (syntax-case stx ()
    [(app arg ...)
     (let loop ([args (syntax->list #'(arg ...))] [ids null] [result null])
       (cond 
         [(and (null? args) (null? ids))
          (datum->syntax #'here `(#%app ,@(reverse result)) stx stx)]
         [(null? args)
          (datum->syntax #'here `(lambda ,(reverse ids) ,(datum->syntax #'here `(#%app ,@(reverse result)) stx stx)) stx stx)]
         [(and (identifier? (car args)) (free-identifier=? (car args) #'_))
          (let ([tmp (syntax-track-origin (car (generate-temporaries '(_))) (car args) #'_)])
            (loop (cdr args) (cons tmp ids) (cons tmp result)))]
         [else
          (loop (cdr args) ids (cons (car args) result))]))]))

(provide (rename-out [-app #%app]))
