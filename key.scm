(import (chicken process-context))

(declare (uses config))
  
;;
;; Help key me!
;;
(define (key-display-help)
  (print "Usage: marks key [action] [args...]\n"
         "Details:\n"
		 "  add         [label] [key]             Add a key with a label\n"
		 "  use    (s)  [label]                   Switch the default key\n"
		 "  copy   (c)  [src label] [dest label]  Copy the key from one label to another label\n"
		 "  delete (d)  [label]                   Delete a key with the given label\n"
		 "  list   (ls)                           List all keys and labels\n"
		 "  show                                  Show the default key\n"
		 "  help   (?)                            Display this\n"))

;;
;; Key Management
;;
(define (key-main args)
  (let ([action (car args)] [parms (cdr args)])
    (cond
      ((in action '(add) eq?) )
      ((in action '(use s) eq?) )
      ((in action '(copy c) eq?) )
      ((in action '(delete d) eq?) )
      ((in action '(list ls) eq?) )
      ((in action '(show) eq?) )
      ((in action '(help ?) eq?) )
      (else))))