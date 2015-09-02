#lang racket/base

(require (for-syntax racket/base))

(define-syntax (-app stx)
  (define pos (syntax-position stx))
  (define span (syntax-span stx))
  (syntax-case stx ()
    [(app arg ...)
     (let loop ([args (syntax->list #'(arg ...))] [ids null] [result null])
       (cond 
         [(and (null? args) (null? ids))
          (datum->syntax #'here `(#%app ,@(reverse result)) stx stx)]
         [(null? args)
          (syntax-property
           (datum->syntax #'here
                          `(lambda ,(reverse ids)
                             ,(datum->syntax #'here `(#%app ,@(reverse result)) stx stx))
                          stx stx)
           'mouse-over-tooltips
           (and pos span
                (vector
                 stx
                 pos
                 (+ pos span)
                 (format "this application is automatically a function using _"))))]
         [(and (identifier? (car args)) (free-identifier=? (car args) #'_))
          (let* ([_-id (car args)]
                 [_-pos (syntax-position _-id)]
                 [_-span (syntax-span _-id)]
                 [id (car (generate-temporaries '(_)))]
                 [tmp
                  (syntax-property 
                   (syntax-track-origin
                    id (car args) #'_)
                   'mouse-over-tooltips
                   (and _-pos _-span
                        (vector id
                                (sub1 _-pos)
                                (sub1 (+ _-pos _-span))
                                "_ is the parameter to the anonymous function")))])
            (loop (cdr args) (cons tmp ids) (cons tmp result)))]
         [else
          (loop (cdr args) ids (cons (car args) result))]))]))

(provide (rename-out [-app #%app]))
