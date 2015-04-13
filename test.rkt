#lang racket

(require images/flomap
         racket/draw
         racket/gui/base)

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
(define (open-file filename canvas)
  (define base-image (read-bitmap filename (get-symbol filename)))
  (define dc (send canvas get-dc))
  (send dc draw-bitmap base-image 0 0)
  base-image)

(provide open-file)
