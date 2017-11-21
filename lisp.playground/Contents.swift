//: Playground - Lisp: a place where people can play

import Foundation
import LispCore

var lisp = Lisp()

var programLines:[String] = []

programLines.append("(defun yo () 'hello)")
programLines.append("(yo)")

do {
    for line in programLines {
        print(try lisp.interpret(program: line))
    }
} catch let error {
    print("error: \(error)")
}
