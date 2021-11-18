(declare (unit browser))

(import
  (chicken string)
  (chicken file)
  (chicken pathname)
  (chicken platform)
  (chicken process)
  (chicken process-context))

;;
;; A list of possible browsers for marks to use.
;; They all accept a URL as an argument.
;;
;; Example: browser-command [url]
;;
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
    "surf")) ; TODO Resolve stdin conflicts and add suport for terminal browsers such as lynx.

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

;;
;; Execute the browser process.
;;
(define (run-unix-browser browser url)
  (process-fork (lambda ()
      (process-execute browser (list url)))))

;;
;; Find & Open a browser on a UNIX-like OS.
;;
(define (open-unix-browser url)
  (let loop ([browsers possible-unix-browsers])
    (if (null? browsers) #f
      (let ([browser (search-unix-path (car browsers))])
        (if browser
          (run-unix-browser browser url)
          (loop (cdr browsers)))))))

;;
;; Open a URL in the user's default browser.
;;
(define (open-browser url)
  (let ([platform (software-type)] [version (software-version)])
    (cond
      [(and (eq? 'unix platform) (eq? 'linux version))
        (when (not (open-unix-browser url))
          (error-msg "Unable to find a browser."))]
      [else (error-msg "Your platform isn't supported for opening a browser.")])))