#lang racket

(require images/flomap
         racket/draw
         racket/gui/base)

;;http://docs.racket-lang.org/images/index.html
;;http://docs.racket-lang.org/images/flomap_title.html


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Backend image opening code;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

(define (white-balance fm type)
  (cond
    ((eq? type 'fluorescent) (enhance-blue fm 0.75))
    ((eq? type 'outdoors) (begin (enhance-red fm 0.75)
                                 (enhance-green fm 0.75)))))

(define (adjust-gamma fm k)
  (flomap-append-components (flomap-take-components fm 1)
                            (fm* k (flomap-drop-components fm 1))))

(define (dispatch method k bmp)
  (define fm (bitmap->flomap bmp))
    (cond
      ((eq? method 'enhance-blue) (flomap->bitmap (enhance-blue fm k)))
      ((eq? method 'enhance-red) (flomap->bitmap (enhance-red fm k)))
      ((eq? method 'enhance-green) (flomap->bitmap (enhance-green fm k)))
      ((eq? method 'saturation) (flomap->bitmap (saturation fm k)))
      ((eq? method 'white-balance) (flomap->bitmap (white-balance fm k)))
      ((eq? method 'gamma) (flomap->bitmap (adjust-gamma fm k)))))

(provide dispatch)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;painting tools;;;;;;;;;;;;;;;;;;;;;;
(define (freeform-brush x y bmp)
  (define-values (bmp-x bmp-y) (flomap-size (bitmap->flomap bmp)))
  (flomap->bitmap
    (fm+ (bitmap->flomap bmp)
       (draw-flomap
        (lambda (fm-dc)
          (send fm-dc set-alpha 0)
          (send fm-dc set-background "black")
          (send fm-dc clear)
          (send fm-dc set-alpha 1)
          (send fm-dc set-pen "black" 5 'dot)
          (send fm-dc draw-point x y))
        bmp-x bmp-y))))

(define (line-brush x1 x2 y1 y2 bmp)
  (define-values (bmp-x bmp-y) (flomap-size (bitmap->flomap bmp)))
  (flomap->bitmap
    (fm+ (bitmap->flomap bmp)
       (draw-flomap
        (lambda (fm-dc)
          (send fm-dc set-alpha 0)
          (send fm-dc set-background "black")
          (send fm-dc clear)
          (send fm-dc set-alpha 1)
          (send fm-dc set-pen "black" 5 'solid)
          (send fm-dc draw-line x1 y1 x2 y2))
        bmp-x bmp-y))))

(define (erase x y bmp)
  (define-values (bmp-x bmp-y) (flomap-size (bitmap->flomap bmp)))
  (flomap->bitmap
    (fm- (bitmap->flomap bmp)
       (draw-flomap
        (lambda (fm-dc)
          (send fm-dc set-alpha 0)
          (send fm-dc set-background "white")
          (send fm-dc clear)
          (send fm-dc set-alpha 1)
          (send fm-dc set-pen "black" 15 'dot)
          (send fm-dc draw-point x y))
        bmp-x bmp-y))))

(provide erase)
(provide line-brush)
(provide freeform-brush)
