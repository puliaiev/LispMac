//
//  LispCoreTests.swift
//  LispCoreTests
//
//  Created by Sergii Puliaiev on 6/16/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import XCTest
@testable import LispCore

class ParserTests: XCTestCase {

    var parser = Parser()

    override func setUp() {
        super.setUp()

        parser = Parser()
    }

    func testTokenize() {
        XCTAssertEqual(parser.tokenize(program: "a"), [.text("a")])
        XCTAssertEqual(parser.tokenize(program: "(quote a)"), [.open, .text("quote"), .text("a"), .close])
    }

    func testBasic() {
        XCTAssertEqual(parser.parse(program: "a"), Expression.atom("a"))

        XCTAssertEqual(parser.parse(program: "(quote a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))

        XCTAssertEqual(parser.parse(program: "(quote (quote a) a)"), Expression.list([Expression.atom("quote"), Expression.list([Expression.atom("quote"), Expression.atom("a")]), Expression.atom("a")]))
    }

    func testQuote() {
        XCTAssertEqual(parser.parse(program: "'a"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))
    }

    func testSpaces() {
        XCTAssertEqual(parser.parse(program: "(quote  a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))

        XCTAssertEqual(parser.parse(program: "(quote    a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))

        XCTAssertEqual(parser.parse(program: " (quote a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))

        XCTAssertEqual(parser.parse(program: "(quote\n a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))
    }
}
