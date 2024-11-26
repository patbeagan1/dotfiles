#!/usr/bin/env -S sbcl --script

;;; Load Quicklisp
;;; only needs to be done one time 
;; (load "~/Downloads/quicklisp.lisp")
;; (quicklisp-quickstart::install)

;;; Load Quicklisp
(load (merge-pathnames "quicklisp/setup.lisp"
                       (user-homedir-pathname)))

(defun guessing-game (maxNum)
  "A simple guessing game where the player tries to guess a random number between 1 and 100."
  (let ((secret-number (1+ (random maxNum)))  ; Generate a random number between 1 and 100
        (guess nil)
        (attempts 0))
    (format t "Welcome to the guessing game!~%")
    (format t "I have selected a random number between 1 and ~d. Try to guess it!~%" maxNum)
    (loop
      (format t "Enter your guess: ")
      (setq guess (parse-integer (read-line) :junk-allowed t))
      (incf attempts)
      (cond
        ((< guess secret-number)
         (format t "Too low! Try again.~%"))
        ((> guess secret-number)
         (format t "Too high! Try again.~%"))
        (t
         (format t "Congratulations! You guessed the correct number ~a in ~a attempts.~%"
                 secret-number attempts)
         (return))))))  ; End the loop and the game when the correct number is guessed

(guessing-game 400)
