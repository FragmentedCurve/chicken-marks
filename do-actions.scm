(declare (unit do-actions))

(declare (uses bookie))
(declare (uses config))
(declare (uses subshell))
(declare (uses browser))

(import ansi-escape-sequences)

(import (chicken plist))
(import (chicken string))
(import (chicken io))
(import (chicken port))

(define (do-list-all)
  (print-entry-list
    (bookie-parse
      (bookie-search (bookie-server) [config-key (config-default-key)] "" ""))
    do-color: (terminal-port? (current-output-port))))

(define (do-raw)
  (display (string-chomp
    (bookie-search (bookie-server) [config-key (config-default-key)] "" ""))))

(define (do-search url tag-list)
  (let ([entries (bookie-parse
                   (bookie-search (bookie-server) [config-key (config-default-key)]
                     url
                     (tagline->string tag-list)))])

    ;; If the output is going to a tty, use the marks subshell.
    ;; If not, just dump the results.
    (if (terminal-port? (current-output-port))
      (if (= 1 (length entries))
        (begin
          (print-entry (car entries) do-color: #t)
          (open-browser (entry-url (car entries))))
        (marks-subshell entries))
      (print-entry-list entries))))
  
(define (do-tag-search tag-list)
  (do-search "" tag-list))

(define (do-url-search url-snippet)
  (do-search url-snippet '()))

(define (do-add url tagline)
  (bookie-add (bookie-server) [config-key (config-default-key)] url (tagline->string tagline)))

(define (do-append url tagline)
  (let ([entry (bookie-parse (bookie-search (bookie-server) [config-key (config-default-key)]  url ""))])
    (cond
      ([null? entry]
        (error-msg "Failed to find an entry with URL: " url))
      ([> (length entry) 1]
        (error-msg "Too many entries found with URL: " url))
      (else
        (do-add url (append (entry-tagline (car entry)) tagline))))))
  
(define (do-delete url)
  (bookie-delete (bookie-server) [config-key (config-default-key)] url ""))

(define (do-kill)
  (bookie-kill (bookie-server) [config-key (config-default-key)] "" ""))

(define (do-import filename)
  (error-msg "Importing is not implemented yet."))

(define (do-ingest filename)
  ; TODO Handle errors when opening the file fails
  (let ([file (call-with-input-file
                filename
                (lambda (port)
                  (read-string #f port)))])
    (for-each (lambda (e)
        (print "Ingesting -- " (entry-url e))
        (do-add (entry-url e) (entry-tagline e)))
      (bookie-parse file))))

(define (print-entry e #!key (prefix "") (line-prefix "") (suffix "") (line-suffix "") (do-color #f))
  (display prefix)

  (let ([tagline (conc "TAGS : " (tagline->string (entry-tagline e)))])
    (print
      line-prefix
      (if do-color
        (colorize tagline (config 'tagline-fg-color))
        tagline)
      line-suffix))

  (let ([urlline (conc "URL  : " (entry-url e))])
    (print
      line-prefix
      (if do-color
        (colorize
          urlline
          (config 'urlline-fg-color))
        urlline)
      line-suffix))

  (display suffix))
  
(define (print-entry-list data #!key (do-color #f))
  (let loop ([walk data] [sep ""])
    (when (not (null? walk))
      (print-entry (car walk) prefix: sep do-color: do-color)
      (loop (cdr walk) "\n"))))

(define (colorize s color)
  (cond
    [(equal? color "green")
      (set-text '(fg-green) s)]
    [(equal? color "red")
      (set-text '(fg-red) s)]
    [(equal? color "blue")
      (set-text '(fg-blue) s)]
    [(equal? color "yellow")
      (set-text '(fg-yellow) s)]
    [(equal? color "white")
      (set-text '(fg-blue) s)]
    [(equal? color "cyan")
      (set-text '(fg-cyan) s)]
    [(equal? color "magenta")
      (set-text '(fg-magenta) s)]
    [(equal? color "black")
      (set-text '(fg-black) s)]
    [else s]))
