#lang racket

(require racket/gui/base
         racket/include
         images/flomap
         (file "test.rkt"))



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

;USed for spacing
(define overall (new horizontal-panel% [parent frame]
                     ))

(define iconpanel (new vertical-panel% [parent overall]
                       [style '(border)]
                       [border 2]
                       [min-width 100]
                       [stretchable-width #f]))

(define openbutton (new button% [parent iconpanel]
                        [label "Open"]
                        ; Button Click, changes the message
                        [callback (lambda (button event)
                                    (open-file "file.bmp" canvas)
                                    (send (read-bitmap "file.bmp") save-file "data.png" 'png))]))

(define colorbutton (new button% [parent iconpanel]
                         [label "Color Balance"]
                         [callback (lambda (button event)
                                     (send colDialog show #t))]))

(define gwbutton (new button% [parent iconpanel]
                      [label "Gamma/White"]
                      ; Button Click, changes the message
                      [callback (lambda (button event)
                                  (send gwdia show #t))]))

(define canvas (new canvas% [parent overall]
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
                              (open-file "data.png" canvas)
                              (send gwdia show #f)
                              )]))



(define colorOk (new button% [parent colDialog]
                     [label "OK"]
                     ; Button Click, changes the message
                     [callback (lambda (button event)
                                 (send msg set-label "LINK UP")
                                 (send (dispatch 'enhance-red 
                                                 (/ (send rslider get-value) 100) 
                                                 (read-bitmap "data.png"))
                                       save-file "data.png" 'png)
                                 (send (dispatch 'enhance-green
                                                 (/ (send gslider get-value) 100) 
                                                 (read-bitmap "data.png"))
                                       save-file "data.png" 'png)
                                 (send (dispatch 'enhance-blue
                                                 (/ (send bslider get-value) 100) 
                                                 (read-bitmap "data.png"))
                                       save-file "data.png" 'png)
                                 (open-file "data.png" canvas)
                                 (send colDialog show #f)
                                 )]))


;;;write button temporarily removed
;(define Write (new button% [parent iconpanel]
;                         [label "Write"]
;                         [callback (lambda (button event)
;                                     (send msg set-label "Writing")
;                                     (open-file "data.png" canvas))]))



