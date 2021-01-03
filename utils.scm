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
    
; TODO: This whitespace functions are shit. CLEAN THEM!
(define (clear-left-whitespace s)
  (set! s (string->list s))
  (do ((c (car s) (car s)))
    ((not (or (equal? c #\space) (equal? c #\tab))) (list->string s))
    (set! s (cdr s))))

(define (clear-right-whitespace s)
  (list->string (reverse (string->list
    (clear-left-whitespace
      (list->string
        (reverse (string->list s))))))))

(define (clear-whitespace s)
  (clear-right-whitespace (clear-left-whitespace s)))
