#lang info

(define collection "fancy-app")
(define scribblings
  '(("main.scrbl" () (library) "fancy-app")))

(define deps '("base"))

(define build-deps
  '("rackunit-lib"
    "racket-doc"
    ["scribble-lib" #:version "1.16"]))
