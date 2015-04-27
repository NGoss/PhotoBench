# PhotoBench

##Authors
Nathan Goss

Eric Wang

##Overview
These days, everything is documented by photos. People take them every day, both of themselves and their lives. Sometimes, these photographers (both amateur and professional) need to make changes to their photos, but they don't want to spend money on expensive photo-editing suites to do so. That's where Photobench comes in. Photobench is a Racket-based photo-editing program which has an emphasis on maintaining the abstraction barrier between the user and the components that actually make up the image. 

![Imgur](http://i.imgur.com/orE34KW.png)

##Concepts Demonstrated
* **The abstraction barrier** is in full force in this project, as not only does it separate the user from the program code, it also separates the backend from the frontend code. In this way, the abstraction barrier is kept at both the user level and the code level.

##External Technology and Libraries
For this project, we used the [/images/flomap](docs.racket-lang.org/images/flomap_title.html) and [/gui/base](http://docs.racket-lang.org/gui/) libraries extensively. In addition to those, we also used the [/draw](http://docs.racket-lang.org/draw/index.html?q=) library, and the [/include](http://docs.racket-lang.org/reference/include.html) library.

##Favorite Lines of Code
####Nathan
My favorite piece of code for this project is a little long, but is an important piece of the backend, as it allowed me to only give the frontend access to one procedure, instead of all of them. Using this code, all procedure calls from the frontend simply go through this and are routed to the desired procedure.
```scheme
define (dispatch method k)
  (define fm (bitmap->flomap base-image))
    (cond
      ((eq? method 'enhance-blue) (flomap->bitmap (enhance-blue fm k)))
      ((eq? method 'enhance-red) (flomap->bitmap (enhance-red fm k)))
      ((eq? method 'enhance-green) (flomap->bitmap (enhance-green fm k)))
      ((eq? method 'saturation) (flomap->bitmap (saturation fm k)))
      ((eq? method 'white-balance) (flomap->bitmap (white-balance fm k)))
      ((eq? method 'gamma) (flomap->bitmap (adjust-gamma fm k)))))

(provide dispatch)
```
####Eric
My favorite bit of code is basically the implementation of one of the OK buttons.  There's a lot to it, but it's really quite simple.  This is one of the linkages between the color handling/drawing code and the GUI iteself.  It crosses the abstraction barrier and allows the program to work.  It trusts the dispatch that is provided and trusts the GUI itself to do its part.
```scheme
(define colorOk (new button% [parent colDialog]
                     [label "OK"]
                     ; Button Click, changes the message
                     [callback (lambda (button event)
                                 (send msg set-label "LINK UP")
                                 (send dc erase)
                                 (send (dispatch 'enhance-red 
                                                 (/ (send rslider get-value) 100) 
                                                 (dispatch 'enhance-green
                                                           (/ (send gslider get-value) 100) 
                                                           (dispatch 'enhance-blue
                                                                     (/ (send bslider get-value) 100) 
                                                                     (read-bitmap "data.png"))))
                                       save-file "data.png" 'png)
                                 (send dc draw-bitmap (read-bitmap "data.png") 0 0)
                                 (send colDialog show #f)
                                 )]))
```

#How to Download and Run
[Latest release is here.](https://github.com/oplS15projects/PhotoBench/releases)

To run, load the GUIbase.rkt file into DrRacket and run it (You do need to have test.rkt in the same directory).

#Changelog
V1.1
Photobench, now with:

* Toolbars functionality, like save and close.

* Popup windows and slider adjustment

* RGB balance

* White balance

* Gamma adjustment

* Saturation


V1.0

* Base GUI added

* Image handling


