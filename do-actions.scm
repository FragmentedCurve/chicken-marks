(declare (unit do-actions))

(declare (uses bookie))
(declare (uses config))
(declare (uses subshell))

(import (chicken plist))
(import (chicken string))

(define (do-list-all)
  (print-entry-list (bookie-parse
    (bookie-search (bookie-server) (cdr marks-current-key) "" ""))))

(define (do-raw)
  (display (string-chomp
    (bookie-search (bookie-server) (cdr marks-current-key) "" ""))))

(define (do-search url tag-list)
  (let ((entries (bookie-parse
      (bookie-search (bookie-server) (cdr marks-current-key)
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
  (bookie-add (bookie-server) (cdr marks-current-key) url (tagline->string tagline)))

(define (do-delete url)
  (bookie-delete (bookie-server) (cdr marks-current-key) url ""))

(define (do-kill)
  (bookie-kill (bookie-server) (cdr marks-current-key)))

(define (do-import filename)
  (print filename))

(define (do-ingest filename)
  (print filename))

(define (print-entry e)
  (print "TAGS : " (tagline->string (entry-tagline e)))
  (print "URL  : " (entry-url e)))
  
(define (print-entry-list data)
  (let loop ((walk data))
    (when (not (null? walk))
      (print-entry (car walk))
      (when (not (null? (cdr walk))) (print)) ; avoid print an extra newline at the end
      (loop (cdr walk)))))
