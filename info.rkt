#lang info

(define collection "fancy-app")
(define scribblings
  '(("main.scrbl" () (library) "fancy-app")))
(define deps '("base"))
(define build-deps
  '("racket-doc"
    "scribble-lib"))
