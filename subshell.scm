(declare (unit subshell))
(declare (uses bookie))
(declare (uses utils))

(import srfi-1)
(import linenoise)
(import (chicken string))
(import (chicken format))

;;
;; Returns a vector of the form: #(entry-list position window-size)
;;
(define (window l #!key (position 0) (size 10))
  (vector l position size ))

(define (window-abs w i)
  (+ i (* (window-size w) (window-position w))))

(define (window-count w)
  (ceiling (/ (window-length w) (window-size w))))

(define (window-size w)
  (vector-ref w 2))

(define (window-set-size! w size)
  (vector-set! w 2 size))

(define (window-next! w)
  (when (< [window-position w] [- (window-count w) 1])
    (vector-set! w 1 (add1 (window-position w)))))

(define (window-prev! w)
  (when [> (window-position w) 0]
    (vector-set! w 1 (- (window-position w) 1))))

(define (window-position w)
  (vector-ref w 1))

(define (valid-window-index? w i)
  (and
    [>= i 0]
    [< i (window-size w)]
    [< (window-abs w i) (window-length w)]))
  
(define (window-set-position! w position)
  (vector-set! w 1 position))

(define (window-length w)
  (length (vector-ref w 0)))

(define (window-ref w i)
  (list-ref (vector-ref w 0) (window-abs w i)))

(define (window-for-each w f)  
  (do
    ([i 0 (add1 i)])
    ([not (valid-window-index? w i)])
    (f (window-ref w i) i)))

(define (print-entry-window w)
  (window-for-each w
    (lambda (e i)
      (print-entry e
        suffix: "\n"
        line-prefix: (sprintf "~A) " i)))))

;;
;; Ignore all non-numeric chars & convert chars to numbers.
;;
(define (all-to-number l)
  (map (lambda (n) (char-digit->integer n))
    (filter char-numeric? l)))

;;
;; Entry point for the marks subshell.
;;
(define (marks-subshell entries)
  (define (delete-entry entries e)
    (let loop ((temp entries))
      (if (string=? (entry-url e) (entry-url (car temp)))
        (cdr temp)
        (cons (car temp) (loop (cdr temp))))))

  (let ([w (window entries)])
    (print-entry-window w) ; Print the window before prompting
    
    (let loop ([cmd (subshell-prompt)])
      (when (not (in (subshell-cmd-action cmd) '("quit" "q")))
        (cond
          [(in (subshell-cmd-action cmd) '("help" "?" "h")) (subshell-help)]
          
          ; Replace the tagline (add)
          [(in (subshell-cmd-action cmd) '("add" "a"))
            (for-each
              (lambda (i)
                (let ([e (window-ref w i)])
                  (set-car! e (subshell-cmd-tagline cmd))
                  (do-add (entry-url e) (entry-tagline e))))
              (subshell-cmd-nums cmd))]
  
          ; Append a tagline
          [(in (subshell-cmd-action cmd) '("append" "aa"))
            (for-each
              (lambda (i)
                (let ([e (window-ref w i)])
                  (set-car! e (append (entry-tagline e) (subshell-cmd-tagline cmd)))
                  (do-add (entry-url e) (entry-tagline e))))
              (subshell-cmd-nums cmd))]
  
          ; Delete an entry
          [(in (subshell-cmd-action cmd) '("delete" "d"))
            (for-each
              (lambda (i)
                (let ([e (window-ref w i)])
                  (do-delete (entry-url e))
                  (set! entries (delete-entry entries e))
                  (set! w (window w position: (window-position w)))))
              (subshell-cmd-nums cmd))]
  
          ; Go to next window
          [(in (subshell-cmd-action cmd) '("next" "]"))
            (window-next! w)
            (print-entry-window w)]
  
          ; Go to previous window
          [(in (subshell-cmd-action cmd) '("prev" "["))
            (window-prev! w)
            (print-entry-window w)]
  
          ; Display current window
          [(in (subshell-cmd-action cmd) '("print" "p")) (print-entry-window w)]
  
          ; I dunno
          [else (print "Nothing to do with that.")])
  
        (loop (subshell-prompt))))))

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
