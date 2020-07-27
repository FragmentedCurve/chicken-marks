;;; 
;;; Parses config files and generates them if they don't exist.
;;;
;;; EXPORTED SYMBOLS
;;; marks-settings -- A property list (plist) consisting of variables
;;;                   from the config file with user defined values.

(declare (unit config))
(declare (uses bookie))

(import (chicken io))
(import (chicken file))
(import (chicken pathname))
(import (chicken process-context))
(import (chicken plist))
(import (chicken string))
(import (chicken platform))

(define marks-current-key (cons 'default (bookie-generate-key)))
(define (marks-config-directory) (make-absolute-pathname (system-config-directory) "marks"))

; TODO: This whitespace functions are shit. CLEAN THEM!
(define (clear-left-whitespace s)
  (set! s (string->list s))
  (do ((c (car s) (car s)))
    ((not (or (equal? c #\space) (equal? c #\tab))) (list->string s))
    (set! s (cdr s))))

(define (clear-right-whitespace s)
  (list->string (reverse (string->list
    (clear-left-whitespace
      (list->string
        (reverse (string->list s))))))))

(define (clear-whitespace s)
  (clear-right-whitespace (clear-left-whitespace s)))

;;
;; Parse the settings file set the properties
;;
(define (read-config plist-sym filename)
  (let ((file-port (open-input-file filename)))
    (do
      ((line "" (read-line file-port))
      (sline '())
      (count 0 (+ 1 count)))
      ((eof-object? line) (close-input-port file-port))
      (begin
        (set! sline (map clear-whitespace (string-split line "=")))
        (cond
          ((= 0 (length sline))
            (begin) ) ; Ignore blank lines
          ((= 2 (length sline))
            (put! plist-sym (string->symbol (car sline)) (car (cdr sline))))
          (else
            (signal (make-property-condition 'exn 'message
              (string-append filename ":" (->string count) ": SYNTAX ERROR")))))))))

;;
;; Input bookie keys from the user's 'keys' file
;;
(define (read-keys plist-sym filename)
  (define (parse-line line)
    (let ((parts (string-split line " ")))
      (if (= 2 (length parts))
        (if (equal? #\> (string-ref (car parts) 0))
          (begin
            (set! (list-ref parts 0) (substring (car parts) 1))
            (set! marks-current-key (cons (string->symbol (car parts)) (car (cdr parts)))))
          (put! 'marks-keys (car parts) (car (cdr parts)))))))
        
  (let ((file-port (open-input-file filename)))
    (do
      ((line (read-line file-port) (read-line file-port)))
      ((eof-object? line) (close-input-port file-port))
      (parse-line line))))

;;
;; Set defaults & read config/key files
;;
(define (init-config)
  ; Fill plist  with default setting values
  (put! 'marks-settings 'server "https://bookie.pacopascal.com")
  (put! 'marks-settings 'tagline-background "0")
  (put! 'marks-settings 'urlline-background "0")
  (put! 'marks-settings 'tagline-foreground "0")
  (put! 'marls-settings 'urlline-foreground "0")
  
  (let*
    ((config-dir (marks-config-directory))
      (key-file (make-pathname config-dir "keys"))
      (config-file (make-pathname config-dir "settings")))

    (if (not (directory-exists? config-dir))
      (begin
        (create-directory config-dir #t)))

    (if (file-exists? config-file)
      (read-config 'marks-settings config-file))

    (if (file-exists? key-file)
      (read-keys 'keys key-file))))
        
;(define (save-config) )

;;
;; Returns the bookies server.
;; Same as (get 'marks-settings 'server)
;;
(define (bookie-server)
  (get 'marks-settings 'server))

(define (marks-setting var) (get 'marks-settings var))