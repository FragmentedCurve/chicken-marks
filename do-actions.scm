(declare (unit do-actions))

(declare (uses bookie))
(declare (uses config))
(declare (uses subshell))

(import (chicken plist))
(import (chicken string))

(define (do-list-all)
  (print-entry-list (bookie-parse-nn
    (bookie-search (bookie-server) (cdr marks-current-key) "" ""))))

(define (do-raw)
  (display (string-chomp
    (bookie-search (bookie-server) (cdr marks-current-key) "" ""))))

(define (do-search url tag-list)
  (let ((entries (bookie-parse-nn
    (bookie-search (bookie-server) (cdr marks-current-key)
      url
      (apply string-append (map ->string (intersperse tag-list" ")))))))
    (if (= 1 (length entries))
      (print-entry (car entries))
      (marks-subshell entries))))
  
(define (do-tag-search tag-list)
  (do-search "" tag-list))

(define (do-url-search url-snippet)
  (do-search url-snippet '()))

(define (do-add url tagline)
  (bookie-add (bookie-server) (cdr marsk-current-key) url tagline))

(define (do-delete url)
  (bookie-delete (bookie-server) (cdr marks-current-key) url))

(define (do-kill)
  (bookie-kill (bookie-server) (cdr marks-current-key)))

(define (do-import filename)
  (print filename))

(define (do-ingest filename)
  (print filename))

;;
;; Typical display of a bookie entry in marks.
;;
(define (print-entry entry)
  ; TODO: Make a nice way of handling color. Also, don't let the user input plain ANSI codes.
  ;       Let them type in "green" etc. in their settings file.
  (print
    "\x1b[" ; ANSI terminal escape
    (marks-setting 'tagline-background) ";"
    (marks-setting 'tagline-foreground) "m"
    "TAGS : " (car entry) "\x1b[0m")
  (print
    "\x1b[" ; ANSI terminal escape
    (marks-setting 'urlline-background) ";"
    (marks-setting 'urlline-foreground) "m"
    "URL  : " (cdr entry) "\x1b[0m"))

;;
;; Print out a list of bookie entries to the console.
;;
(define (print-entry-list data)
  (let loop ((sep "") (d data))
    (if (< 0 (length d))
      (begin
        (display sep)
        (print-entry (car d))
        (loop "\n" (cdr d))))))
