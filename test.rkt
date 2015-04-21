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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;level-manipulation code;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (saturation fm sat)
  (define-values (x y) (flomap-size fm))
  (define fmsat (build-flomap 1 x y (lambda (k x y) sat)))
  (fm* fm fmsat))

(define (get-red fm)
  (fm* fm (flomap-ref-component fm 1)))

(define (enhance-red fm k)
  (define fmred (saturation (get-red fm) k))
  (fm+ fm fmred))

(define (get-green fm)
  (fm* fm (flomap-ref-component fm 2)))

(define (enhance-green fm k)
  (define fmgreen (saturation (get-green fm) k))
  (fm+ fm fmgreen))

(define (get-blue fm)
  (fm* fm (flomap-ref-component fm 3)))

(define (enhance-blue fm k)
  (define fmblue (saturation (get-blue fm) k))
  (fm+ fm fmblue))

(define (dispatch method k)
  (define fm (bitmap->flomap base-image))
    (cond
      ((eq? method 'enhance-blue) (flomap->bitmap (enhance-blue fm k)))
      ((eq? method 'enhance-red) (flomap->bitmap (enhance-red fm k)))
      ((eq? method 'enhance-green) (flomap->bitmap (enhance-green fm k)))
      ((eq? method 'saturation) (flomap->bitmap (saturation fm k)))
      ((eq? method 'white-balance) (flomap->bitmap (white-balance fm k)))
      ((eq? method 'gamma) (flomap->bitmap (adjust-gamma fm k)))))

(provide dispatch)
