(declare (unit subshell))

(import linenoise)
(import (chicken string))
(import (chicken io))

(define (window-count l)
  (ceiling (/ (length l) 10)))
  
(define (is-all-numeric? l)
  (let loop ()
    (if (char-numeric? (car l))
      (begin
        (set! l (cdr l))
        (loop))
      #f))
  #t)

(define (all-to-number l)
  (let loop ((walk l))
    (set-car! walk (string->number (string (car walk))))
    (if (null? (cdr walk)) l (loop (cdr walk)))))

(define (marks-subshell entries)
  (define (print-window entries position)
    (do
      ((i 0 (add1 i)))
      ((or (= (+ i position) (length entries)) (= i 10)))
      (display i)
      (display ") ")
      (print-entry (list-ref entries (+ position i)))
      (print)))

  (define (get-urls entries position numlist)
    (let loop ((result '()) (nums numlist))
      (if (null? nums) result
          (loop (cons (list-ref entries (+ position (car nums))) result) (cdr nums)))))
  
  (let loop ((cmd (subshell-prompt)) (position 0))
    (if (not (in (car cmd) '("quit" "q")))
      (begin
        (cond
          ((in (car cmd) '("help" "?" "h")) (subshell-help))
          ; TODO: Finish implementing these.
          ((in (car cmd) '("add" "a"))
            (for-each (lambda (e) (do-add (cdr e) (caddr cmd)))
              (get-urls entries position (cadr cmd))))
          ((in (car cmd) '("append" "aa"))
            (for-each (lambda (e) (do-add (cdr e) (append (car e) (caddr cmd))))
              (get-urls entries position (cadr cmd))))
          ((in (car cmd) '("delete" "d")) (print "DELETE SOMETHING"))
          ((in (car cmd) '("next" "n"))
            (if (< position (- (length entries) 10))
              (set! position (+ position 10))))
          ((in (car cmd) '("prev" "nn"))
            (if (<= 0 (- position 10)) 
              (set! position (- position 10))))
          ((in (car cmd) '("print" "p")) (print-window entries position))
          (else (print "Nothing to do with that.")))
        (loop (subshell-prompt) position)))))

(define (subshell-prompt)
  (let ((user-input (linenoise "marks] ")) (result '()))
    (set! user-input (string-split user-input " "))

    (when (<= 1 (length user-input))
      (set! result (list (car user-input))))
    (when (<= 2 (length user-input))
      (set-cdr! result (list (all-to-number (string->list (cadr user-input))))))
    (when (<= 3 (length user-input))
      (set! result
        (join
          (list result (map
              (lambda (k) (string-split k " "))
              (cddr user-input))))))
            

    (if (null? user-input) (subshell-prompt) result)))

(define (subshell-help)
  (print "===============================================\n"
         "add    (a)   [0-9]... [tags]   Replace tags\n"
         "append (aa)  [0-9]... [tags]   Append tags\n"
         "delete (d)   [0-9]...          Delete entries\n\n"
         
         "next   (n)\n"
         "prev   (nn)\n"
         "print  (p)\n\n"
         
         "quit   (q)                     Quit\n"
         "help   (?)                     Display this\n"
         "==============================================="))
