# PhotoBench

##Authors
Nathan Goss

Eric Wang

##Overview
Photobench is a picture editor made in Racket, that aspires to have a lot of functionality and uses.  Photos can be chosen by the user for use in the editor.

##Screenshot
(insert a screenshot here. You may opt to get rid of the title for it. You need at least one screenshot. Make it actually appear here, don't just add a link.)

Here's a demonstration of how to display an image that's uploaded to this repo:
![screenshot showing env diagram](withdraw.png)

##Concepts Demonstrated
Identify the OPL concepts demonstrated in your project. Be brief. A simple list and example is sufficient. 
* **The abstraction barrier** is in full force, as the user does not need to know how any of the code behind it works, just the program itself.
* 
**I have no ideas for anything else**

##External Technology and Libraries
Briefly describe the existing technology you utilized, and how you used it. Provide a link to that technology(ies).

##Favorite Lines of Code
####Nathan
Each team member should identify a favorite line of code, expression, or procedure written by them, and explain what it does. Why is it your favorite? What OPL philosophy does it embody?
Remember code looks something like this:
```scheme
(map (lambda (x) (foldr compose functions)) data)
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
