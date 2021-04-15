;;; 
;;; Parses config files and generates them if they don't exist.
;;;

(declare (unit config))
(declare (uses bookie))
(declare (uses utils))

(import (chicken io))
(import (chicken file))
(import (chicken pathname))
(import (chicken process-context))
(import (chicken plist))
(import (chicken string))
(import (chicken platform))
(import (chicken format))
(import (chicken sort))

(define (marks-config-directory) (make-absolute-pathname (system-config-directory) "marks"))

(define (config-key label #!optional key)
  (when key
    (put! 'marks-config-keys label key))
  (get 'marks-config-keys label))

(define (config-key-del! label)
  (remprop! 'marks-config-keys label))
  
(define (config-key-labels)
  (sort!
    (let loop ([walk (symbol-plist 'marks-config-keys)])
      (if (null? walk) '()
        (cons (car walk) (loop (cddr walk)))))
    (lambda (a b)
      (string<? (symbol->string a) (symbol->string b)))))
    
(define (config-default-key #!optional label)
  (when label
    (put! 'marks-default-key-label 'label label))
  (get 'marks-default-key-label 'label))

(define (config prop #!optional value)
  (when value
    (put! 'marks-settings prop value))
  (get 'marks-settings prop))

;;
;; Parse the settings file set the properties
;;
(define (read-config filename)
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
            (config (string->symbol (car sline)) (cadr sline)))
          (else
            (signal (make-property-condition 'exn 'message
              (string-append filename ":" (->string count) ": SYNTAX ERROR")))))))))

;;
;; Input bookie keys from the user's 'keys' file
;;
(define (read-keys filename)
  (define (parse-line line)
    (let ([parts (string-split line " ")])
      (when (= 2 (length parts))
        (when [equal? #\> (string-ref (car parts) 0)]
          (set-car! parts (list->string (cdr (string->list (car parts))))) ; Chop off #\>
          (config-key (string->symbol (car parts)) (cadr parts))
          (config-default-key (string->symbol (car parts))))
        (config-key (string->symbol (car parts)) (cadr parts)))))

  (let ([file-port (open-input-file filename)])
    (let loop ([line (read-line file-port)])
      (when [not (eof-object? line)]
        (parse-line line)
        (loop (read-line file-port))))
    (close-input-port file-port)))

(define (write-keys filename)
  (let ([file-port (open-output-file filename)])
    (for-each
      (lambda (label)
        (write-line
          (sprintf "~A~A ~A" (if [eqv? (config-default-key) label] ">" "") (symbol->string label) (config-key label))
          file-port))
      (config-key-labels))))
;;
;; Set defaults & read config/key files
;;
(define (init-config)
  ; Fill plist  with default setting values
  (config 'server "https://bookie.pacopascal.com")
  (config 'tagline-fg-color #f)
  (config 'urlline-fg-color #f)
  
  (let*
    ((config-dir (marks-config-directory))
      (key-file (make-pathname config-dir "keys"))
      (config-file (make-pathname config-dir "settings")))

    (when (not (directory-exists? config-dir))
        (create-directory config-dir #t))

    (when (file-exists? config-file)
      (read-config config-file))

    (when (file-exists? key-file)
      (read-keys key-file)))

  ; If no keys exist, generate one.
  (when [null? (config-key-labels)]
    (config-key 'default (bookie-generate-key))
    (config-default-key 'default)))

(define (save-config)
  (let*
    ((config-dir (marks-config-directory))
      (key-file (make-pathname config-dir "keys"))
      (config-file (make-pathname config-dir "settings")))
    (write-keys key-file)))

;;
;; Returns the bookies server.
;; Same as (get 'marks-settings 'server)
;;
(define (bookie-server)
  (config 'server))