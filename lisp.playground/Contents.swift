//: Playground - Lisp: a place where people can play

import Foundation
import LispCore

var lisp = Lisp()

let program = "(defun pair (x y) (cons x (cons y '())))"

print(lisp.interpret(program: program))
