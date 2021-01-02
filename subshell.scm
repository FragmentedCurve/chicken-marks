(declare (unit subshell))
(declare (uses bookie))

(import linenoise)
(import (chicken string))
(import (chicken io))

; TODO: Make a collection of window- functions that each with the a vector of this form #(entry-list position window-size)

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

  (define (delete-entry entries e)
    (let loop ((temp entries))
      (if (string=? (entry-url e) (entry-url (car temp)))
        (cdr temp)
        (cons (car temp) (loop (cdr temp))))))

  ; Print the first window before prompting
  (print-window entries 0)
  
  (let loop ((cmd (subshell-prompt)) (position 0))
    (when (not (in (subshell-cmd-action cmd) '("quit" "q")))
      (cond
        ((in (subshell-cmd-action cmd) '("help" "?" "h")) (subshell-help))
        
        ; Replace the tagline (add)
        ((in (subshell-cmd-action cmd) '("add" "a"))
          (for-each
            (lambda (e)
              (set-car! e (subshell-cmd-tagline cmd))
              (do-add (entry-url e) (entry-tagline e)))
            (get-urls entries position (subshell-cmd-nums cmd))))

        ; Append a tagline
        ((in (subshell-cmd-action cmd) '("append" "aa"))
          (for-each
            (lambda (e)
              (set-car! e (append (entry-tagline e) (subshell-cmd-tagline cmd)))
              (do-add (entry-url e) (entry-tagline e)))
            (get-urls entries position (subshell-cmd-nums cmd))))

        ; Delete an entry
        ((in (subshell-cmd-action cmd) '("delete" "d"))
          (for-each
            (lambda (e)
              (do-delete (entry-url e))
              (set! entries (delete-entry entries e)))
            (get-urls entries position (subshell-cmd-nums cmd))))

        ; Go to next window
        ((in (subshell-cmd-action cmd) '("next" "]"))
          (when (< position (- (length entries) 10))
            (set! position (+ position 10))
            (print-window entries position)))

        ; Go to previous window
        ((in (subshell-cmd-action cmd) '("prev" "["))
          (when (<= 0 (- position 10)) 
            (set! position (- position 10))
            (print-window entries position)))

        ; Display current window
        ((in (subshell-cmd-action cmd) '("print" "p")) (print-window entries position))

        ; I dunno
        (else (print "Nothing to do with that.")))
        
      (loop (subshell-prompt) position))))

(define (subshell-prompt)
  (subshell-parse (linenoise "marks] ")))
  
;;
;; string-input is a subshell command such as "a 123 here are tags".
;; Returns a vector of the form #("a" (1 2 3) (here are tags)).
;; 
(define (subshell-parse string-input)
  (let ((s (string-split string-input " "))
        (result (vector "next" '() '()))) ; default action is 'next'

    (when (<= 1 (length s))
      (vector-set! result 0 (car s)))
    (when (<= 2 (length s))
      (vector-set! result 1 (all-to-number (string->list (cadr s)))))
    (when (<= 3 (length s))
      (vector-set! result 2 (apply string->tagline (cddr s))))
    result))

(define (subshell-cmd-action cmd)
  (vector-ref cmd 0))

(define (subshell-cmd-nums cmd)
  (vector-ref cmd 1))

(define (subshell-cmd-tagline cmd)
  (vector-ref cmd 2))

;(define (subshell-nums->urls entries position numlist)
;    (let loop ((result '()) (nums numlist))
;      (if (null? nums) result
;          (loop (cons (list-ref entries (+ position (car nums))) result) (cdr nums)))))

(define (subshell-help)
  (print "===============================================\n"
         "add    (a)   [0-9]... [tags]   Replace tags\n"
         "append (aa)  [0-9]... [tags]   Append tags\n"
         "delete (d)   [0-9]...          Delete entries\n\n"
         
         "next   (])\n"
         "prev   ([)\n"
         "print  (p)\n\n"
         
         "quit   (q)                     Quit\n"
         "help   (?)                     Display this\n"
         "==============================================="))
