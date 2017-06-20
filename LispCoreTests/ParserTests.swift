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

    func testBasic() {
        XCTAssertEqual(parser.parse(program: "(quote a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))
    }

    func testQuote() {
        XCTAssertEqual(parser.parse(program: "'a"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))
    }

    func testSpaces() {
        XCTAssertEqual(parser.parse(program: "(quote  a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))

        XCTAssertEqual(parser.parse(program: "(quote    a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))

        XCTAssertEqual(parser.parse(program: " (quote a)"), Expression.list([Expression.atom("quote"), Expression.atom("a")]))
    }
}
