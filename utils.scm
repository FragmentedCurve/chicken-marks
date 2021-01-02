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
