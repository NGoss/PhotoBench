#lang racket

(require images/flomap
         racket/draw)

;;http://docs.racket-lang.org/images/index.html
;;http://docs.racket-lang.org/images/flomap_title.html

(define fm
  (draw-flomap
   (lambda (fm-dc)
     (send fm-dc set-alpha 0)
     (send fm-dc set-background "black")
     (send fm-dc clear)
     (send fm-dc set-alpha 1/3)
     (send fm-dc translate 2 2)
     ;;(send fm-dc set-pen "white" 5 'solid)
     (send fm-dc set-brush "red" 'solid)
     (send fm-dc draw-ellipse 0 0 192 192)
     (send fm-dc set-brush "green" 'solid)
     (send fm-dc draw-ellipse 64 0 192 192)
     (send fm-dc set-brush "blue" 'solid)
     (send fm-dc draw-ellipse 32 44 192 192))
   260 240))

(define filename "usa.bmp")

(define (get-symbol filename)
  (define extension (substring filename (- (string-length filename) 3)))
  (cond
    ((equal? extension "gif") 'gif)
    ((equal? extension "bmp") 'bmp)
    ((equal? extension "png") 'png)
    ((equal? extension "jpg") 'jpg)))

;(read-bitmap)
(define base-image (read-bitmap filename (get-symbol filename)))

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