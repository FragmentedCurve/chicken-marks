(import (chicken process-context))
(import (chicken condition))

(declare (uses do-actions))
(declare (uses config))

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

;;
;; Help me!
;;
(define (display-help)
  (begin
    (print "Usage: marks [action] [args...]\n" 
           "       marks [label]\n\n"
           "Action Details:\n"
           "  add      (a)   [url]  [tagline]   Add an entry\n"
           "  append   (aa)  [url]  [tagline]   Append tags to the end of the tagline\n"
           "  delete   (d)   [url]              Delete an entry\n"
           "  search   (s)   [url]  [tags]      Search url and tags\n"
           "  tag      (t)   [tags]             Search taglines for the given tags\n"
           "  url      (u)   [url]              Search url\n"
           "  ls                                List all entries\n"
           "  keys                              List all keys\n"
           "  key                               Sub menu for managing keys\n"
           "  raw                               Output raw database dump\n"
           "  ingest         [filename]         Import a bookie backup file\n"
           "  import         [filename]         Import Netscape bookmark file\n"
           "  kill kill kill                    Wipe out all your data from the cloud\n"
           "  help     (?)                      Display this")))

(define (parse-cmd-args args)
  (handle-exceptions e
    (cond
      ((and ((condition-predicate 'exn) e) ((condition-predicate 'type) e))
        display-help) )

    (let ((action (car args)))
      (cond
        ((string=? action "ls")
          do-list-all)
        ((string=? action "key")
          do-key)
        ((string=? action "raw")
          do-raw)
        ((in action '("help" "?" "h"))
          display-help)

        ((string=? action "ingest")
          do-ingest)
        ((string=? action "import")
          do-import)

        ((in action '("search" "s"))
          do-search)
        ((in action '("tag" "t"))
          do-tag-search)
        ((in action '("url" "u"))
          do-url-search)
        ((in action '("add" "a"))
          do-add)
        ((in action '("delete" "d"))
          do-delete)
        (else (lambda () (print "Nothing to do.")))))))

;;
;; Let's do this!
;;
(define (main)
  (init-config)  ; Makes a plist called marks-settings

  (handle-exceptions e
    (cond 
      ((and ((condition-predicate 'exn) e) ((condition-predicate 'args) e))
        (begin
          (print "Not enough information given.")
          (exit 1)))
      (else (abort e)))

    (let*
      ((args (command-line-arguments)) (action (parse-cmd-args args)))

      (cond
        ((in action (list display-help do-list-all do-raw) eq?)
          (action) )
        ((in action (list do-search do-add) eq?)
          (let ((first (car (cdr args))) (second (cdr (cdr args))))
            (if (= 0 (length second))
              (abort (make-composite-condition (make-property-condition 'exn) (make-property-condition 'args)))) 
            (action (car (cdr args)) (cdr (cdr args)))))
        ((in action (list do-delete do-import do-ingest do-url-search) eq?)
          (action (car (cdr args))))
        ((in action (list do-tag-search))
          (action (cdr args)))
        (else (action)))))
  (exit 0))

(main)
