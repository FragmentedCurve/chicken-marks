(declare (unit do-actions))

(declare (uses bookie))
(declare (uses config))
(declare (uses subshell))

(import (chicken plist))
(import (chicken string))
(import (chicken io))

(define (do-list-all)
  (print-entry-list (bookie-parse
    (bookie-search (bookie-server) [config-key (config-default-key)] "" ""))))

(define (do-raw)
  (display (string-chomp
    (bookie-search (bookie-server) [config-key (config-default-key)] "" ""))))

(define (do-search url tag-list)
  (let ((entries (bookie-parse
      (bookie-search (bookie-server) [config-key (config-default-key)]
        url
        (tagline->string tag-list)))))

    (if (= 1 (length entries))
      (print-entry (car entries))
      (marks-subshell entries))))
  
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
        (print "Error -- Failed to find an entry with URL: " url))
      ([> (length entry) 1]
        (print "Error -- Too many entries found with URL: " url))
      (else
        (do-add url (append (entry-tagline (car entry)) tagline))))))
  
(define (do-delete url)
  (bookie-delete (bookie-server) [config-key (config-default-key)] url ""))

(define (do-kill)
  (bookie-kill (bookie-server) [config-key (config-default-key)]))

(define (do-import filename)
  (print filename))

(define (do-ingest filename)
  (let ([file (open-input-file filename)])
    ; TODO Handle errors when opening the file fails
    (for-each (lambda (e)
        (print "Ingesting -- " (entry-url e))
        (do-add (entry-url e) (entry-tagline e)))
      (bookie-parse (apply conc (intersperse (read-lines file) "\n"))))))

(define (print-entry e #!key (prefix "") (line-prefix "") (suffix "") (line-suffix ""))
  (display prefix)
  (print line-prefix "TAGS : " (tagline->string (entry-tagline e)) line-suffix)
  (print line-prefix "URL  : " (entry-url e) line-suffix)
  (display suffix))
  
(define (print-entry-list data)
  (let loop ([walk data] [sep ""])
    (when (not (null? walk))
      (print-entry (car walk) prefix: sep)
      (loop (cdr walk) "\n"))))
