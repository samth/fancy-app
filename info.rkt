#lang info

(define collection "fancy-app")
(define version "1.1")
(define scribblings
  '(("main.scrbl" () (library) "fancy-app")))

(define deps
  '(["base" #:version "6.4"]))

(define build-deps
  '("rackunit-lib"
    "racket-doc"
    ["scribble-lib" #:version "1.16"]))
