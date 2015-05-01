#lang racket

(require racket/gui/base
         racket/include
         images/flomap
         (file "test.rkt"))

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

;;Save button inside the file option
(define savebutt (new menu-item%        ;;save, creates a popup dialog
                      [label "Save"]
                      [parent menufile]
                      [callback (lambda (b e) (let ((m (new dialog% [label "Are you sure?"]
                                                            [parent frame])))
                                                (define n (new text-field% [label "Name:"] [parent m] [init-value "data"]))
                                                (define o (new button% [parent m]
                                                               [label "OK"]
                                                               [callback (lambda (button event)
                                                                           (send current save-file (string-append (send n get-value)
                                                                                                                  ".png") 'png)
                                                                           (send m show #f))]))
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

(define test2 (new menu-item%             ;;not really needed.  Couldn't think of anything.
                   [label "Placeholder"]
                   [parent menuedit]
                   [callback (lambda (b e)(send msg set-label "Placeholder for future procedures."))]))


;Used for spacing, Contains the lefthand buttons
(define overall (new horizontal-panel% [parent frame]
                     ))

(define iconpanel (new vertical-panel% [parent overall]
                       [style '(border)]
                       [border 2]
                       [min-width 100]
                       [stretchable-width #f]))

;;Used to open files.  Can open user-named files in the same directory
;;Also initiates the counters for undo/redo
(define openbutton 
  (new button% [parent iconpanel]
       [label "Open"]
       [callback 
        (lambda (button event)
          (let ((m (new dialog% [label "Open"]
                        [parent frame])))
            (define n (new text-field% [label "File Name:"] [parent m] [init-value "fm"]))
            (define o (new button% [parent m]
                           [label "OK"]
                           [callback (lambda (button event)
                                       (cond [(equal? (send n get-value) "fm")
                                              (set! maximg 0)
                                              (set! counter 0)
                                              (save fm)
                                              (load (- counter 1))]
                                             [else (set! maximg 0)
                                                   (set! counter 0)
                                                   (save (read-bitmap (send n get-value)))
                                                   (load (- counter 1))])
                                       (send m show #f)
                                       )]))
            (define p (new button% [parent m]
                           [label "Close"]
                           [callback (lambda (button event)
                                       (send m show #f))]))
            (send m show #t)))]))

;;Color change button.  Pops up a new dialog with actual changing options.
(define colorbutton (new button% [parent iconpanel]
                         [label "Color Balance"]
                         [callback (lambda (button event)
                                     (send colDialog show #t))]))

;;Gamma/white/saturation button.  Similar dialog to colorbutton.
(define gwbutton (new button% [parent iconpanel]
                      [label "Gamma/White"]
                      [callback (lambda (button event)
                                  (send gwdia show #t))]))

;;Contains all the options for the various brushes.  Used to change which mode the brushes are set to.
;;Defaulted to no brush set.
(define brushbox (new list-box% [parent (new horizontal-panel% 
                                             (parent iconpanel)
                                             (min-height 150)
                                             (stretchable-height #f))]
                      [label "Brushes"]
                      [choices (list "Freeform" "Line" "Erase" "None")]
                      [style (list 'single 'vertical-label)]
                      [selection 3]
                      [callback (λ (c e) 
                                  (cond ((send brushbox is-selected? 0) (set! mode 'freeform))
                                        ((send brushbox is-selected? 1) (set! mode 'line))
                                        ((send brushbox is-selected? 2) (set! mode 'erase))
                                        (else (set! mode 'none))))]))

;;Undo button.  Pulls up older images that were previously there.
(define undo (new button% [parent iconpanel]
                  [label "Undo"]
                  [callback (λ (button event) 
                              (cond [(<= counter 1) 
                                     (let ((m (new dialog% [label "Error"]
                                                   [parent frame])))
                                       (define n (new message% [label "You cannot undo what is not there."] [parent m]))
                                       (define o (new button% [parent m]
                                                      [label "OK"]
                                                      [callback (lambda (button event)
                                                                  (send m show #f))]))
                                       (send m show #t))]
                                    [else 
                                     (set! counter (- counter 1))
                                     (set! current (read-bitmap (string-append "data\\data"
                                                                               (number->string (- counter 1) 10)
                                                                               ".png")))
                                     (load (- counter 1))]))]))

;;Redo button.  Only used after undo has been pushed, grabs the next most recent image.
(define redo (new button% [parent iconpanel]
                  [label "Redo"]
                  [callback (λ (button event) 
                              (cond [(equal? counter maximg) 
                                     (let ((m (new dialog% [label "Error"]
                                                   [parent frame])))
                                       (define n (new message% [label "You cannot redo the future."] [parent m]))
                                       (define o (new button% [parent m]
                                                      [label "OK"]
                                                      [callback (lambda (button event)
                                                                  (send m show #f))]))
                                       (send m show #t))]
                                    [else 
                                     (set! counter (+ counter 1))
                                     (set! current (read-bitmap (string-append "data\\data"
                                                                               (number->string (- counter 1) 10)
                                                                               ".png")))
                                     (load (- counter 1))]))]))

;;New canvas class, with overridden on-event.  The new on-event
;;Is used to capture mouse clicks for use with the brushes.  The mouse coordinates
;;get passed on to test.rkt, where all the image handling and drawing is done.
(define my-canvas%
  (class canvas%
    (define/override (on-event event)
      (cond [(and (equal? mode 'line) (send event button-down? 'left)) 
             (set! pt1 (cons (send event get-x) (send event get-y)))]
            [(and (equal? mode 'line) (send event button-up? 'left)) 
             (set! pt2 (cons (send event get-x) (send event get-y)))
             (set! maximg counter)
             (save (line-brush (car pt1) (car pt2) (cdr pt1) (cdr pt2) current))
             (load (- counter 1))]
            
            [(and (equal? mode 'freeform) (send event button-down? 'left))
             (set! tempmap (freeform-brush (send event get-x) (send event get-y) current))]
            [(and (equal? mode 'freeform) (send event dragging?))
             (set! tempmap (freeform-brush (send event get-x) (send event get-y) tempmap))
             (send dc erase)
             (send dc draw-bitmap tempmap (/ imgwidth -2) (/ imgheight -2))]
            [(and (equal? mode 'freeform) (send event button-up? 'left))
             (set! tempmap (freeform-brush (send event get-x) (send event get-y) tempmap))
             (set! maximg counter)
             (save tempmap)
             (load (- counter 1))]
            
            [(and (equal? mode 'erase) (send event button-down? 'left))
             (set! tempmap (erase (send event get-x) (send event get-y) current))]
            [(and (equal? mode 'erase) (send event dragging?))
             (set! tempmap (erase (send event get-x) (send event get-y) tempmap))
             (send dc erase)
             (send dc draw-bitmap tempmap (/ imgwidth -2) (/ imgheight -2))]
            [(and (equal? mode 'erase) (send event button-up? 'left))
             (set! tempmap (erase (send event get-x) (send event get-y) tempmap))
             (set! maximg counter)
             (save tempmap)
             (load (- counter 1))]
            ))
    (super-new)))


;;Initialization of new canvas
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

(define colorOk (new button% [parent colDialog]
                     [label "OK"]
                     [callback (lambda (button event)
                                 (send msg set-label "COLORS CHANGED")
                                 (set! maximg counter)
                                 (save (dispatch 'enhance-red 
                                                 (/ (send rslider get-value) 100) 
                                                 (dispatch 'enhance-green
                                                           (/ (send gslider get-value) 100) 
                                                           (dispatch 'enhance-blue
                                                                     (/ (send bslider get-value) 100) 
                                                                     current))))
                                 (load (- counter 1))
                                 (send colDialog show #f)
                                 )]))

;; The gamma/sat/white balances are here.  Just sliders and the OK button which handles all the calculations.
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
                  (choices (list "Fluorescent" "Outdoors" "None"))
                  (selection 2)))

(define gwOk (new button% [parent gwdia]
                  [label "OK"]
                  [callback (lambda (button event)
                              (set! maximg counter)
                              (send msg set-label "GAMMASAT ARMED")
                              (save (dispatch 'gamma 
                                              (/ (send gammaslider get-value) 100) 
                                              (dispatch 'saturation
                                                        (/ (send satslider get-value) 100) 
                                                        (cond [(equal? (send wbal get-selections) '()) 'none]
                                                              [(= 0 (car (send wbal get-selections))) 
                                                               (dispatch 'white-balance 'fluorescent current)]
                                                              [(= 1 (car (send wbal get-selections))) 
                                                               (dispatch 'white-balance 'fluorescent current)]
                                                              [else 'none]))))
                              (load (- counter 1))
                              (send gwdia show #f)
                              )]))


;Test BMP that is provided and is the default open option.
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

;;;;;;;; Background code ;;;;;;;;;;;;;;;;;

;shortcut to define the drawing context of the canvas
(define dc (send canvas get-dc))

;;The next two are used for drawing the images.  Puts them in the right coordinates.
(define imgheight 0)

(define imgwidth 0)

;;Determines which brush is selected
(define mode 0)

;;The next two  points are used to store the mouse coordinates for the two point line drawing.
(define pt1 (cons 0 0))

(define pt2 (cons 0 0))

;;BMP stored for image manipulation, so no actual saving is needed.
(define tempmap 0)

;;Next three are unneeded.
(define rotate 0)

(define (trigx ptvalue)
  (+ (* (cos rotate) (car ptvalue))
     (* (sin rotate) (cdr ptvalue))))

(define (trigy ptvalue)
  (- (* (cos rotate) (cdr ptvalue))
     (* (sin rotate) (car ptvalue))))

;;The next two variables are used for undo/redo counters.
(define maximg 0)

(define counter 0)

;;shortcut to putting images onto the canvas.
(define (load in)   
  (send dc erase)
  (send dc draw-bitmap (read-bitmap (string-append "data\\data"
                                                   (number->string in 10)
                                                   ".png")) 0 0))

;;saves every image as changes are made.
(define (save in) (send in save-file (string-append "data\\data"
                                                    (number->string maximg 10)
                                                    ".png") 'png)
  (set! current  (read-bitmap (string-append "data\\data"
                                             (number->string maximg 10)
                                             ".png")))
  (set! counter (+ counter 1))
  (set! maximg (+ maximg 1)))

;;what the current image is.
(define current 0)

