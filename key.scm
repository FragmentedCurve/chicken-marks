(declare (unit key))
(declare (uses config))
(declare (uses bookie))

;;
;; Help key me!
;;
(define (key-help #!optional cmd . args)
  (print "Usage: marks key [action] [args...]\n"
         "Details:\n"
		 "  add         [label] [key]             Add a key with a label\n"
		 "  use    (s)  [label]                   Switch the default key\n"
		 "  copy   (c)  [src label] [dest label]  Copy the key from one label to another label\n"
		 "  delete (d)  [label]                   Delete a key with the given label\n"
		 "  list   (ls)                           List all keys and labels\n"
		 "  show                                  Show the default key\n"
		 "  help   (?)                            Display this"))

(define (key-add cmd . args)
  (cond
    ([null? args]
      (print "Error -- No label (and key) given."))
    ([= (length args) 1]
      (config-key (string->symbol (car args)) (bookie-generate-key)))
    ([= (length args) 2]
      (if (bookie-key? (cadr args))
        (config-key (string->symbol (car args)) (cadr args))
        (print "Error -- Invalid bookie key: " (cadr args))))))
      
(define (key-use cmd . args)
  (cond
    ([null? args]
      (print "Error -- No label given."))
    ([config-key (string->symbol (car args))]
      (let* ([label (string->symbol (car args))] [key (config-key label)])
        (print "Now using: " label " (" key ")")
        (config-default-key label)))
    (else
      (print "Error -- Invalid label."))))

(define (key-copy cmd . args)
  (cond
    ([null? args]
      (print "Error -- No source and destination label were given."))
    ([= (length args) 1]
      (print "Error -- A destination label is needed."))
    (else
      (apply key-add (list "copy" (cadr args) (config-key (string->symbol (car args))))))))

(define (key-delete cmd . args)
  (if [null? args]
    (print "Error -- No label given.")
    (config-key-del! (string->symbol (car args)))))
    
(define (key-list #!optional cmd . args)
  (for-each
    (lambda (l)
      (print (if (eqv? l (config-default-key)) "> " "  ") (config-key l) " " l))
    (config-key-labels)))

(define (key-show #!optional cmd . args)
  (print (config-key (config-default-key))))

;;
;; Returns a function with the definition of (func cmd . args)
;;
(define (key-parse args)
  (cond
    ([null? args] key-help)
    ([in (car args) '("add")] key-add)
    ([in (car args) '("use" "s")] key-use)
    ([in (car args) '("copy" "c")] key-copy)
    ([in (car args) '("delete" "d")] key-delete)
    ([in (car args) '("list" "ls")] key-list)
    ([in (car args) '("show")] key-show)
    ([in (car args) '("help" "?")] key-help)
    (else main-nothing)))

;;
;; Key Management
;;
(define (key-main args)
  (apply (key-parse args) args))