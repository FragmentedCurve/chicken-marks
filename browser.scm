(import (chicken string))
(import (chicken file))
(import (chicken pathname))
(import (chicken platform))
(import (chicken process))
(import (chicken process-context))

;;
;; Returns true if the file exists and is executable.
;;
(define (executable-exists? filename)
  (and (file-exists? filename) (file-executable? filename)))

;;
;; Search $PATH on a UNIX-like OS for the filename.
;;
(define (search-unix-path filename)
  (let loop ([paths (string-split (get-environment-variable "PATH") ":")])
    (let* ([dir (car paths)] [path (make-pathname dir filename)])
      (cond
        [(null? path) #f]
        [(executable-exists? path) path]
        [else (loop (cdr paths))]))))

;;
;; Attempt to open the URL by using xdg-open to find the default browser.
;;
(define (browser-via-xdg url)
  (let ([xdg-path (search-unix-path "xdg-open")])
    (if xdg-path
      (process-run (conc "sh -c '2>&1 " xdg-path " " url " > /dev/null'")) ; Shell command: sh -c '2>&1 xdg-open URL > /dev/null'
      #f)))

;;
;; Open a URL in the user's default browser.
;;
(define (open-browser url)
  (let ([platform (software-type)] [version (software-version)])
    (cond
      [(eq? 'windows platform)
        (error-msg "Can't open the browser on windows yet.")]
      [(eq? 'unix platform)
        (when (not (browser-via-xdg url))
          (error-msg "Unable to open browser. Failed to find xdg-open."))]
      [else (error-msg "Your platform isn't supported for opening a browser.")])))