;;;
;;; This file supplies functions for communicating with the Bookie web API.
;;; The code here is self contained and independent from the rest of marks.
;;; Therefore, it may easily be taken out and used elsewhere.
;;;

(declare (unit bookie))

(import http-client)
(import (chicken random))
(import (chicken io))
(import (chicken string))

(define bookie-alphabet (string->list "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"))
(define bookie-key-length 69)

(define (bookie-add server key url tagline)
  ; TODO: Instead of using string-append, use a uri function analogous to make-absolute-pathname.
  (with-input-from-request (string-append server "/add")
    `((key . ,key) (url . ,url) (tag . ,tagline))
    read-string))

(define (bookie-search server key url tagline)
  (with-input-from-request (string-append server "/search")
    `((key . ,key) (url . ,url) (tag . ,tagline))
    read-string))
  
(define (bookie-delete server key url tagline)
  (with-input-from-request (string-append server "/delete")
    `((key . ,key) (url . ,url))
    read-string))

(define (bookie-kill server key url tagline)
  (with-input-from-request (string-append server "/kill")
    `((key . ,key)) read-string))

;;
;; Generate and return a random bookie key.
;;
(define (bookie-generate-key)
  (do
    ((count bookie-key-length (- count 1))
    (result
      (list (list-ref bookie-alphabet (pseudo-random-integer (length bookie-alphabet))))
      (append result (list (list-ref bookie-alphabet (pseudo-random-integer (length bookie-alphabet)))))))
    ((= 1 count) (list->string result))))

;;
;; Returns #t if k is a valid key string.
;;
(define (bookie-key? k)
  (do
    ((result (= bookie-key-length (string-length k))) (i 0 (+ 1 i)))
    ((or (not result) (= i (string-length k))) result)
    (let ((c (string-ref k i)))
      (if (not (in c bookie-alphabet)) ; TODO: Don't use (in). Be independent!
          (set! result #f)))))

;;
;; Return true if there are illegal characters in the string.
;;
(define (bookie-dirty-string? s)
  (begin))

;;
;; Parses bookie nn data. (Entries are separated by newline-line)
;; Returns a list of pairs where the pairs are (tagline . url)
;;
(define (bookie-parse-nn s)
  (do
    ((data (string-split s "\n") (cddr data))
      (result '()))
    ((null? data) result)
    (set! result (cons (cons (car data) (cadr data)) result))))