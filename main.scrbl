#lang scribble/manual

@(require (for-label fancy-app
                     (except-in racket/base #%app))
          scribble/example)

@(define (make-fancy-eval)
   (make-base-eval #:lang 'racket/base
                   '(require fancy-app)))

@(define-syntax-rule (fancy-examples body ...)
   (examples #:eval (make-fancy-eval) body ...))

@title{Fancy App: Scala-Style Magic Lambdas}
@defmodule[fancy-app]
@author[@author+email["Sam Tobin-Hochstadt" "samth@ccs.neu.edu"]]

This package provides a simple shorthand for defining anonymous functions. When
required, writing @racket[(+ _ 1)] becomes equivalent to writing
@racket[(λ (v) (+ v 1))].

@defform[(#%app expr ...)]{
 Equivalent to normal function application as in @racketmodname[racket/base]
 @emph{unless} any @racket[expr] is a @racket[_]. In that case, the expression
 is transformed into an anonymous function expression with one argument for each
 @racket[_] found among the given @racket[expr]s. Uses of @racket[_] are
 converted to positional arguments from left to right.

 @(fancy-examples
   (eval:check (map (+ 1 _) (list 1 2 3)) '(2 3 4))
   (eval:check (map (- _ 1) (list 1 2 3)) '(0 1 2))
   (eval:check (map (- _ _) (list 10 20 30) (list 1 2 3)) '(9 18 27)))

 Note that a use of @racket[_] that is @emph{nested} within one of the given
 @racket[expr]s does not count. Additionally, using @racket[_] after a keyword
 is not treated specially and does not trigger creation of a keyword argument.
 @seclink["rest-args" #:doc '(lib "scribblings/guide/guide.scrbl")]{Rest
  arguments} are not supported.

 @(fancy-examples
   (eval:error (+ 1 (+ _ 2)))
   (define (add/kw a #:to b) (+ a b))
   (define add2 (add/kw 2 #:to _))
   (add2 10)
   (eval:error (add2 #:to 10)))}
