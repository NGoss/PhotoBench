#lang racket

(require images/flomap
         racket/draw)

;;http://docs.racket-lang.org/images/index.html
;;http://docs.racket-lang.org/images/flomap_title.html


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Backend image opening code;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define filename "usa.bmp")                  ;;Set the name of the file to be opened...

(define (get-symbol filename)
  (define extension (substring filename (- (string-length filename) 3)))
  (cond
    ((equal? extension "gif") 'gif)
    ((equal? extension "bmp") 'bmp)
    ((equal? extension "png") 'png)
    ((equal? extension "jpg") 'jpg)))

;(read-bitmap)
(define base-image (read-bitmap filename (get-symbol filename)))
