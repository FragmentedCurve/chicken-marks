(declare (unit utils))

;;
;; Return true if the needle is found in the list (haystack).
;; If a comparision function (cmp) isn't given, equal? is used.
;;
(define (in needle haystack #!optional cmp)
  (if (not cmp) (set! cmp equal?))
  (let loop ()
    (cond
      ((= 0 (length haystack)) #f)
      ((cmp needle (car haystack)) #t)
      (else 
        (set! haystack (cdr haystack))
        (loop)))))

(define (not-null? x)
  (not (null? x)))

(define (char-digit->integer c)
  (cond
    [(equal? c #\0) 0]
    [(equal? c #\1) 1]
    [(equal? c #\2) 2]
    [(equal? c #\3) 3]
    [(equal? c #\4) 4]
    [(equal? c #\5) 5]
    [(equal? c #\6) 6]
    [(equal? c #\7) 7]
    [(equal? c #\8) 8]
    [(equal? c #\9) 9]
    [else #f]))
    