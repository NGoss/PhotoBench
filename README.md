# PhotoBench

##Authors
Nathan Goss

Eric Wang

##Overview
These days, everything is documented by photos. People take them every day, both of themselves and their lives. Sometimes, these photographers (both amateur and professional) need to make changes to their photos, but they don't want to spend money on expensive photo-editing suites to do so. That's where Photobench comes in. Photobench is a Racket-based photo-editing program which has an emphasis on maintaining the abstraction barrier between the user and the components that actually make up the image. 

##Screenshot
(insert a screenshot here. You may opt to get rid of the title for it. You need at least one screenshot. Make it actually appear here, don't just add a link.)

Here's a demonstration of how to display an image that's uploaded to this repo:
![screenshot showing env diagram](withdraw.png)

##Concepts Demonstrated
Identify the OPL concepts demonstrated in your project. Be brief. A simple list and example is sufficient. 
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
This expression reads in a regular expression and elegantly matches it against a pre-existing hashmap....
```scheme
(let* ((expr (convert-to-regexp (read-line my-in-port)))
             (matches (flatten
                       (hash-map *words*
                                 (lambda (key value)
                                   (if (regexp-match expr key) key '()))))))
  matches)
```

##Additional Remarks
Anything else you want to say in your report. Can rename or remove this section.

#How to Download and Run
You may want to link to your latest release for easy downloading by people (such as Mark).

Include what file to run, what to do with that file, how to interact with the app when its running, etc. 

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
