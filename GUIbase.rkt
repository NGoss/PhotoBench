#lang racket

(require racket/gui/base
         racket/include
         images/flomap
         (file "test.rkt"))



;;;TO BE CAHNGED FURTHER
;Spin needs to properly center, without clipping
;;Spin also needs a user selected number
;Open Needs a user selected filename
;Undo
;Redo
;Do trig on line drawings so that spin doesn't break it


;output file
;(define out (open-output-file "data.png" #:exists 'replace))

;;Creates the top level window
(define frame (new frame%
                   [label "Photobench"]
                   [width 900]
                   [height 600]))

;;Words for the window
(define msg (new message% [parent frame]
                 [label "HELLO! HELLO! HELLO! HELLO!"]
                 [auto-resize #t]))


;;Menu bar, start
(define menubar (new menu-bar% [parent frame]))

(define menufile (new menu%              ;;file menu
                      [label "File"]
                      [parent menubar]))

(define menuedit (new menu%              ;;edit menu
                      [label "Edit"]
                      [parent menubar]))


(define savebutt (new menu-item%        ;;save, creates a popup dialog
                      [label "Save"]
                      [parent menufile]
                      [callback (lambda (b e) (let ((m (new dialog% [label "Are you sure?"]
                                                            [parent frame])))
                                                (define n (new text-field% [label "Name:"] [parent m] [init-value "data.png"]))
                                                (define o (new button% [parent m]
                                                               [label "OK"]
                                                               [callback (lambda (button event)
                                                                           (rename-file-or-directory "data.png"
                                                                                                     (string-append (send n get-value)
                                                                                                                    ".png")))]))
                                                (define p (new button% [parent m]
                                                               [label "Close"]
                                                               [callback (lambda (button event)
                                                                           (send m show #f))]))
                                                (send m show #t)))
                                ]))

(define test (new menu-item%             ;;Close function
                  [label "Close"]
                  [parent menufile]
                  [callback (lambda (b e)(send frame show #f))]))

(define test2 (new menu-item%             ;;placeholder
                   [label "asdasf2"]
                   [parent menuedit]
                   [callback (lambda (b e)(send msg set-label "doing edit stuff"))]))

;Used for spacing, Contains the lefthand buttons
(define overall (new horizontal-panel% [parent frame]
                     ))

(define iconpanel (new vertical-panel% [parent overall]
                       [style '(border)]
                       [border 2]
                       [min-width 100]
                       [stretchable-width #f]))

(define openbutton (new button% [parent iconpanel]
                        [label "Open"]
                        [callback (lambda (button event)
                                    (send fm save-file "data.png" 'png)
                                    (setheight)
                                    (setwidth)
                                    (send dc set-origin (/ imgwidth 2) (/ imgheight 2))
                                    (redraw)
                                    )]))

(define colorbutton (new button% [parent iconpanel]
                         [label "Color Balance"]
                         [callback (lambda (button event)
                                     (send colDialog show #t))]))

(define gwbutton (new button% [parent iconpanel]
                      [label "Gamma/White"]
                      [callback (lambda (button event)
                                  (send gwdia show #t))]))

(define spin (new button% [parent iconpanel]
                  [label "Spin"]
                  [callback (lambda (button event)
                              (send dc rotate (/ pi 8))
                              (redraw)
                              )]))

(define brushbox (new list-box% [parent (new horizontal-panel% 
                                             (parent iconpanel)
                                             (min-height 150)
                                             (stretchable-height #f))]
                      [label "Brushes"]
                      [choices (list "Freeform" "Line" "Erase" "None")]
                      [style (list 'single 'vertical-label)]
                      [callback (λ (c e) 
                                  (cond ((send brushbox is-selected? 0) (set! mode 'freeform))
                                        ((send brushbox is-selected? 1) (set! mode 'line))
                                        ((send brushbox is-selected? 2) (set! mode 'erase))
                                        (else (set! mode 'none))))]))



(define my-canvas%
  (class canvas%
    (define/override (on-event event)
      (cond [(and (equal? mode 'line) (send event button-down? 'left)) 
             (set! pt1 (cons (send event get-x) (send event get-y)))]
            [(and (equal? mode 'line) (send event button-up? 'left)) 
             (set! pt2 (cons (send event get-x) (send event get-y)))
             (send (flomap->bitmap (line-brush (car pt1) (car pt2) (cdr pt1) (cdr pt2) (read-bitmap "data.png"))) save-file "data.png" 'png)
             (redraw)]
            [(and (equal? mode 'freeform) (send event button-down? 'left))
             (set! tempmap (flomap->bitmap (freeform-brush (send event get-x) (send event get-y) (read-bitmap "data.png"))))]
            [(and (equal? mode 'freeform) (send event dragging?))
             (set! tempmap (flomap->bitmap (freeform-brush (send event get-x) (send event get-y) tempmap)))
             (send dc erase)
             (send dc draw-bitmap tempmap (/ imgwidth -2) (/ imgheight -2))]
            [(and (equal? mode 'freeform) (send event button-up? 'left))
             (set! tempmap (flomap->bitmap (freeform-brush (send event get-x) (send event get-y) tempmap)))
             (send tempmap save-file "data.png" 'png)
             (redraw)]
            [(and (equal? mode 'erase) (send event button-down? 'left))
             (set! tempmap (flomap->bitmap (erase (send event get-x) (send event get-y) (read-bitmap "data.png"))))]
            [(and (equal? mode 'erase) (send event dragging?))
             (set! tempmap (flomap->bitmap (erase (send event get-x) (send event get-y) tempmap)))
             (send dc erase)
             (send dc draw-bitmap tempmap (/ imgwidth -2) (/ imgheight -2))]
            [(and (equal? mode 'erase) (send event button-up? 'left))
             (set! tempmap (flomap->bitmap (erase (send event get-x) (send event get-y) tempmap)))
             (send tempmap save-file "data.png" 'png)
             (redraw)]
             ))
    (super-new)))



(define canvas (new my-canvas% [parent overall]
                    [style '(border)]))


(send frame show #t)


;;;;;;;; Color sliders here ;;;;;;;;;;;;;;;
(define colDialog (new dialog% [label "Color Change"]
                       [parent frame]))

(define rslider (new slider%
                     (label "Red       ")
                     (parent colDialog)
                     (min-value 0)
                     (max-value 200)
                     (init-value 100)
                     (min-width 200)
                     (stretchable-width #f)))

(define gslider (new slider%
                     (label "Green    ")
                     (parent colDialog)
                     (min-value 0)
                     (max-value 200)
                     (init-value 100)
                     (min-width 200)
                     (stretchable-width #f)))

(define bslider (new slider%
                     (label "Blue      ")
                     (parent colDialog)
                     (min-value 0)
                     (max-value 200)
                     (init-value 100)
                     (min-width 200)
                     (stretchable-width #f)))

(define gwdia (new dialog% [label "Gamma/White"]
                   [parent frame]))

(define gammaslider (new slider%
                         (label "Gamma")
                         (parent gwdia)
                         (min-value 0)
                         (max-value 200)
                         (init-value 100)
                         (min-width 200)
                         (stretchable-width #f)))

(define satslider (new slider%
                       (label "Saturation")
                       (parent gwdia)
                       (min-value 0)
                       (max-value 200)
                       (init-value 100)
                       (min-width 200)
                       (stretchable-width #f)))

(define wbal (new list-box%
                  (label "White Balance    ")
                  (parent gwdia)
                  (choices (list "Fluorescent" "Outdoors" "None"))))

(define gwOk (new button% [parent gwdia]
                  [label "OK"]
                  [callback (lambda (button event)
                              (send (dispatch 'gamma 
                                              (/ (send gammaslider get-value) 100) 
                                              (read-bitmap "data.png"))
                                    save-file "data.png" 'png)
                              (send (dispatch 'saturation
                                              (/ (send satslider get-value) 100) 
                                              (read-bitmap "data.png"))
                                    save-file "data.png" 'png)
                              (cond [(equal? (send wbal get-selections) '()) 'none]
                                    [(= 0 (car (send wbal get-selections))) 
                                     (send (dispatch 'white-balance 'fluorescent (read-bitmap "data.png"))
                                           save-file "data.png" 'png)]
                                    [(= 1 (car (send wbal get-selections))) 
                                     (send (dispatch 'white-balance 'fluorescent (read-bitmap "data.png"))
                                           save-file "data.png" 'png)]
                                    [else 'none]) 
                              (redraw)
                              (send gwdia show #f)
                              )]))



(define colorOk (new button% [parent colDialog]
                     [label "OK"]
                     ; Button Click, changes the message
                     [callback (lambda (button event)
                                 (send msg set-label "LINK UP")
                                 (send (dispatch 'enhance-red 
                                                 (/ (send rslider get-value) 100) 
                                                 (dispatch 'enhance-green
                                                           (/ (send gslider get-value) 100) 
                                                           (dispatch 'enhance-blue
                                                                     (/ (send bslider get-value) 100) 
                                                                     (read-bitmap "data.png"))))
                                       save-file "data.png" 'png)
                                 (redraw)
                                 (send colDialog show #f)
                                 )]))




;test bmp
(define fm
  (flomap->bitmap
   (draw-flomap
    (lambda (fm-dc)
      (send fm-dc set-alpha 0)
      (send fm-dc set-background "black")
      (send fm-dc clear)
      (send fm-dc set-alpha 1/3)
      (send fm-dc translate 2 2)
      (send fm-dc set-brush "red" 'solid)
      (send fm-dc draw-ellipse 0 0 192 192)
      (send fm-dc set-brush "green" 'solid)
      (send fm-dc draw-ellipse 64 0 192 192)
      (send fm-dc set-brush "blue" 'solid)
      (send fm-dc draw-ellipse 32 44 192 192))
    260 240)))

;; Background code

;shortcut to define the drawing context of the canvas
(define dc (send canvas get-dc))

(define imgheight 0)

(define imgwidth 0)

(define (setheight) (set! imgheight (send (read-bitmap "data.png") get-height)))

(define (setwidth) (set! imgwidth (send (read-bitmap "data.png") get-width)))

(define mode 0)

(define pt1 (cons 0 0))

(define pt2 (cons 0 0))

(define redraw (λ () (send dc erase)
                 (send dc draw-bitmap (read-bitmap "data.png") (/ imgwidth -2) (/ imgheight -2))))

(define tempmap 0)

