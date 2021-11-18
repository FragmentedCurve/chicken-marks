(declare (unit main))

(import
  (chicken process-context)
  (chicken plist))

;;
;; Help me!
;;
(define (main-help #!optional cmd . args)
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
         "  kill kill kill                    Wipe out all your data from the cloud\n"
         "  help     (?)                      Display this"))

(define (main-add cmd . args)
  (cond
    ([null? args]
      (error-msg "You need to give a URL and tagline."))
    ([= (length args) 1]
      (error-msg  "You must give a tagline for " (car args)))
    (else
      (do-add (car args) (apply string->tagline (cdr args))))))

(define (main-append cmd . args)
  (cond
    ([null? args]
      (error-msg  "You need to give a URL and tagline."))
    ([= (length args) 1]
      (error-msg "You must give a tagline for " (car args)))
    (else
      (do-append (car args) (apply string->tagline (cdr args))))))

(define (main-delete cmd . args)
  (cond
    ([null? args]
      (error-msg "You need to give a URL."))
    (else
      (do-delete (car args)))))

(define (main-search cmd . args)
  (cond
    ([null? args]
      (error-msg "A URL substring is needed and tags."))
    ([= (length args) 1]
      (error-msg "You must also give a tags to search."))
    (else
      (do-search (car args) (apply string->tagline (cdr args))))))

(define (main-tag cmd . args)
  (cond
    ([null? args]
      (error-msg "Tags are needed."))
    (else
      (do-tag-search (apply string->tagline args)))))

(define (main-url cmd . args)
  (cond
    ([null? args]
      (error-msg "A URL substring is needed."))
    (else
      (do-url-search (car args)))))

(define (main-ls #!optional cmd . args)
  (do-list-all))

(define (main-keys #!optional cmd . args)
  (key-main '("list")))

(define (main-key cmd . args)
  (key-main args))

(define (main-raw #!optional cmd . args)
  (do-raw))
  
(define (main-ingest cmd . args)
  (cond
    ([null? args] (error-msg "No filename given."))
    (else (do-ingest (car args)))))
  
(define (main-import cmd . args)
  ; TODO implement
  (do-import (car args)))
  
(define (main-kill cmd . args)
  (do-kill))

(define (main-nothing cmd . args)
  (print "Nothing to do."))

(define (main-key-switch cmd . args)
  (key-main `("use" ,cmd)))

;;
;; Returns a function with the definition of (func cmd . args)
;;
(define (main-parse args)
  (cond
    ([null? args] main-help)
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
    ([in (car args) '("kill")] main-kill)
    ([in (car args) '("help" "?")] main-help)
    ([in (string->symbol (car args)) (config-key-labels)] main-key-switch)
    (else main-nothing)))

(define (main)
  (init-config)  ; Makes a plist called marks-settings

  (let ([args (command-line-arguments)])
    (apply (main-parse args) args))
  (save-config))