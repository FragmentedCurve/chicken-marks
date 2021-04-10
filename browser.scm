(import (chicken string))
(import (chicken file))
(import (chicken pathname))
(import (chicken platform))
(import (chicken process))
(import (chicken process-context))

(define possible-unix-browsers
  '("xdg-open"
    "brave"
    "firefox"
    "chromium"
    "chrome"
    "google-chrome"
    "google-chrome-stable"
    "midori"
    "ditto"
    "surf"
    "elinks"
    "links"
    "lynx"))

(define possible-windows-browsers '())

(define possible-macos-browsers '())

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
    (cond
      [(null? paths) #f]
      [(executable-exists? (make-pathname (car paths) filename))
        (make-pathname (car paths) filename)]
      [else (loop (cdr paths))])))

(define (run-unix-browser browser url)
  (process-run (conc "sh -c \"2>&1 " browser " '" url "' > /dev/null &\"")))

(define (open-unix-browser url)
  (let loop ([browsers possible-unix-browsers])
    (let ([browser (search-unix-path (car browsers))])
      (cond
        [browser (run-unix-browser browser url)]
        [(null? browsers) #f]
        [else (loop (cdr browsers))]))))

;;
;; Open a URL in the user's default browser.
;;
(define (open-browser url)
  (let ([platform (software-type)] [version (software-version)])
    (cond
      [(eq? 'windows platform)
        (error-msg "Can't open the browser on windows yet.")]
      [(eq? 'unix platform)
        (when (not (open-unix-browser url))
          (error-msg "Unable to find a browser."))]
      [else (error-msg "Your platform isn't supported for opening a browser.")])))