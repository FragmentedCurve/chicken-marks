(import (chicken process-context))

(declare (uses do-actions))
(declare (uses key))
(declare (uses config))
(declare (uses utils))

;;
;; Help me!
;;
(define (main-help cmd . args)
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

(define (main-add cmd . args)
  (cond
    ([null? args]
      (print "Error -- You need to give a URL and tagline."))
    ([= (length args) 1]
      (print "Error -- You must give a tagline for " (car args)))
    (else
      (do-add (car args) (apply string->tagline (cdr args))))))

(define (main-append cmd . args)
  (cond
    ([null? args]
      (print "Error -- You need to give a URL and tagline."))
    ([= (length args) 1]
      (print "Error -- You must give a tagline for " (car args)))
    (else
      (do-append (car args) (apply string->tagline (cdr args))))))

(define (main-delete cmd . args)
  (cond
    ([null? args]
      (print "Error -- You need to give a URL."))
    (else
      (do-delete (car args)))))

(define (main-search cmd . args)
  (cond
    ([null? args]
      (print "Error -- A URL substring is needed and tags."))
    ([= (length args) 1]
      (print "Error -- You must also give a tags to search."))
    (else
      (do-search (car args) (apply string->tagline (cdr args))))))

(define (main-tag cmd . args)
  (cond
    ([null? args]
      (print "Error -- Tags are needed."))
    (else
      (do-tag-search (apply string->tagline args)))))

(define (main-url cmd . args)
  (cond
    ([null? args]
      (print "Error -- A URL substring is needed."))
    (else
      (do-url-search (car args)))))

(define (main-ls cmd . args)
  (do-list-all))

(define (main-keys cmd . args)
  (print cmd args))

(define (main-key cmd . args)
  (print cmd args))

(define (main-raw cmd . args)
  (do-raw))
  
(define (main-ingest cmd . args)
  (print cmd args))
  
(define (main-import cmd . args)
  (print cmd args))
  
(define (main-kill cmd . args)
  (print cmd args))

(define (main-nothing cmd . args)
  (print "Nothing to do."))

;;
;; Returns a function with the definition of (func cmd . args)
;;
(define (main-parse args)
  (cond
    ; TODO Check if action is a key label. If yes, switch to that key.
    ([null? args] (main-help))
    ([in (car args) '("add" "a")] main-add)
    ([in (car args) '("append" "aa")] main-append)
    ([in (car args) '("delete" "d")] main-delete)
    ([in (car args) '("search" "s")] main-search)
    ([in (car args) '("tag" "t")] main-tag)
    ([in (car args) '("url" "u")] main-url)
    ([in (car args) '("ls")] main-ls)
    ([in (car args) '("keys")] main-keys)
    ([in (car args) '("key")] main-key)
    ([in (car args) '("raw")] main-raw)
    ([in (car args) '("ingest")] main-ingest)
    ([in (car args) '("import")] main-import)
    ([in (car args) '("kill")] main-kill)
    ([in (car args) '("help" "?")] main-help)
    (else main-nothing)))
  
(define (main)
  (init-config)  ; Makes a plist called marks-settings

  (let ([args (command-line-arguments)])
    (cond
      ([null? args] (main-help '()))  ; Display help by default
      (else
        (apply (main-parse args) args)))))

(main)