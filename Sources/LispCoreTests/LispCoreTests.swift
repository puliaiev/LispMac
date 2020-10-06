//
//  LispCoreTests.swift
//  LispCoreTests
//
//  Created by Sergii Puliaiev on 6/16/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import XCTest
@testable import LispCore

class LispCoreTests: XCTestCase {

    var lisp: Lisp = Lisp()

    override func setUp() {
        super.setUp()

        lisp = Lisp()
    }

    func testLibFuncNull() {
        XCTAssertEqual(try? lisp.interpret(program: "(null. '())"), "t")
        XCTAssertEqual(try? lisp.interpret(program: "(null. 'x)"), "()")
    }

    func testLibFuncAssoc() {
        XCTAssertEqual(try? lisp.interpret(program: "(assoc. 'x1 (pair. '(x1 x2) '(a b)))"), "a")
    }

    func testLibFuncEval() {
        XCTAssertEqual(try? lisp.interpret(program: "(eval. '(car '(a b)) '())"), "a")
    }

    func testLibFuncAppend() {
        XCTAssertEqual(try? lisp.interpret(program: "(append. '(1 2 3 4) '(5 6 7 8))"), "(1 2 3 4 5 6 7 8)")
    }

    func testQuote() {
        XCTAssertEqual(try? lisp.interpret(program: "(quote a)"), "a")

        XCTAssertEqual(try? lisp.interpret(program: "'a"), "a")

        XCTAssertEqual(try? lisp.interpret(program: "'(a (b (c) d))"), "(a (b (c) d))")
    }

    func testAtom() {
        XCTAssertEqual(try? lisp.interpret(program: "(atom 'a)"), "t")

        XCTAssertEqual(try? lisp.interpret(program: "(atom '(a b c))"), "()")

        XCTAssertEqual(try? lisp.interpret(program: "(atom (atom 'a))"), "t")
    }

    func testEq() {
        XCTAssertEqual(try? lisp.interpret(program: "(eq 'a 'a)"), "t")

        XCTAssertEqual(try? lisp.interpret(program: "(eq 'a 'b)"), "()")

        XCTAssertEqual(try? lisp.interpret(program: "(eq '(a) '(a))"), "t")

        XCTAssertEqual(try? lisp.interpret(program: "(eq '(a a) '(a a))"), "t")

        XCTAssertEqual(try? lisp.interpret(program: "(eq '(a a) '(a b))"), "()")

        XCTAssertEqual(try? lisp.interpret(program: "(eq '(a) '(b))"), "()")
    }

    func testCarCdr() {
        XCTAssertEqual(try? lisp.interpret(program: "(car '(a b c))"), "a")

        XCTAssertThrowsError(try lisp.interpret(program: "(car 'a)"))

        XCTAssertEqual(try? lisp.interpret(program: "(car '())"), "()")

        XCTAssertEqual(try? lisp.interpret(program: "(cdr '(a b c))"), "(b c)")

        XCTAssertEqual(try? lisp.interpret(program: "(cdr '(a))"), "()")

        XCTAssertEqual(try? lisp.interpret(program: "(caar '((a)))"), "a")

        XCTAssertEqual(try? lisp.interpret(program: "(cadr '(() a b))"), "a")

        XCTAssertEqual(try? lisp.interpret(program: "(cddr '(() a b))"), "(b)")
    }

    func testCons() {
        XCTAssertEqual(try? lisp.interpret(program: "(cons 'a '(b c))"), "(a b c)")

        XCTAssertEqual(try? lisp.interpret(program: "(cons 'a '())"), "(a)")
    }

    func testCond() {
        XCTAssertEqual(try? lisp.interpret(program: "(cond ((eq 'a 'b) 'first) ((atom 'a) 'second))"), "second")
    }

    func testLambda() {
        XCTAssertEqual(try? lisp.interpret(program: "((lambda (x y) (cons x (cdr y))) 'z '(a b c))"), "(z b c)")
    }

    func testLabel() {
        XCTAssertEqual(try? lisp.interpret(program: "((label greet (lambda (x) (cond ((atom x) (cons 'hello (cons x '()))) ('t (greet (car x)))))) '(world))"), "(hello world)")
        XCTAssertEqual(try? lisp.interpret(program: "(greet '(world))"), "(hello world)")
    }

    func testDefun() {
        XCTAssertEqual(try? lisp.interpret(program: "(defun null. (x) (eq x '()))"), "null.")
        XCTAssertEqual(try? lisp.interpret(program: "(null. 'a)"), "()")
        XCTAssertEqual(try? lisp.interpret(program: "(null. '())"), "t")
    }
}
