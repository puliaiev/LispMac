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
        XCTAssertEqual(lisp.interpret(program: "(null. '())"), "t")
        XCTAssertEqual(lisp.interpret(program: "(null. 'x)"), "()")
    }

    func testLibFuncAssoc() {
        XCTAssertEqual(lisp.interpret(program: "(assoc. 'x1 (pair. '(x1 x2) '(a b)))"), "a")
    }

    func testLibFuncEval() {
        XCTAssertEqual(lisp.interpret(program: "(eval. '(car '(a b)) '())"), "a")
    }

    func testQuote() {
        XCTAssertEqual(lisp.interpret(program: "(quote a)"), "a")

        XCTAssertEqual(lisp.interpret(program: "'a"), "a")

        XCTAssertEqual(lisp.interpret(program: "'(a (b (c) d))"), "(a (b (c) d))")
    }

    func testAtom() {
        XCTAssertEqual(lisp.interpret(program: "(atom 'a)"), "t")

        XCTAssertEqual(lisp.interpret(program: "(atom '(a b c))"), "()")

        XCTAssertEqual(lisp.interpret(program: "(atom (atom 'a))"), "t")
    }

    func testEq() {
        XCTAssertEqual(lisp.interpret(program: "(eq 'a 'a)"), "t")

        XCTAssertEqual(lisp.interpret(program: "(eq 'a 'b)"), "()")

        XCTAssertEqual(lisp.interpret(program: "(eq '(a) '(a))"), "t")

        XCTAssertEqual(lisp.interpret(program: "(eq '(a a) '(a a))"), "t")

        XCTAssertEqual(lisp.interpret(program: "(eq '(a a) '(a b))"), "()")

        XCTAssertEqual(lisp.interpret(program: "(eq '(a) '(b))"), "()")
    }

    func testCarCdr() {
        XCTAssertEqual(lisp.interpret(program: "(car '(a b c))"), "a")

        XCTAssertEqual(lisp.interpret(program: "(cdr '(a b c))"), "(b c)")

        XCTAssertEqual(lisp.interpret(program: "(cdr '(a))"), "()")
    }

    func testCons() {
        XCTAssertEqual(lisp.interpret(program: "(cons 'a '(b c))"), "(a b c)")

        XCTAssertEqual(lisp.interpret(program: "(cons 'a '())"), "(a)")
    }

    func testCond() {
        XCTAssertEqual(lisp.interpret(program: "(cond ((eq 'a 'b) 'first) ((atom 'a) 'second))"), "second")
    }

    func testLambda() {
        XCTAssertEqual(lisp.interpret(program: "((lambda (x y) (cons x (cdr y))) 'z '(a b c))"), "(z b c)")
    }

    func testLabel() {
        XCTAssertEqual(lisp.interpret(program: "((label greet (lambda (x) (cond ((atom x) (cons 'hello (cons x '()))) ('t (greet (car x)))))) '(world))"), "(hello world)")
        XCTAssertEqual(lisp.interpret(program: "(greet '(world))"), "(hello world)")
    }

    func testDefun() {
        XCTAssertEqual(lisp.interpret(program: "(defun null. (x) (eq x '()))"), "null.")
        XCTAssertEqual(lisp.interpret(program: "(null. 'a)"), "()")
        XCTAssertEqual(lisp.interpret(program: "(null. '())"), "t")
    }
}
