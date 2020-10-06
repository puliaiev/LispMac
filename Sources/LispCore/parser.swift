//
//  parser.swift
//  LispMac
//
//  Created by Sergii Puliaiev on 6/17/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import Foundation

extension CharacterSet {
    func contains(character: Character) -> Bool {
        let unicodeScalars = String(character).unicodeScalars
        guard unicodeScalars.count == 1, let unicodeScalar = unicodeScalars.first else {
            return false
        }

        return self.contains(unicodeScalar)
    }
}

extension String {
    func trimTrailingWhitespace() -> String {
        if let trailingWs = self.range(of: "\\s+$", options: .regularExpression) {
            return self.replacingCharacters(in: trailingWs, with: "")
        } else {
            return self
        }
    }
}

class Parser {
    
    func parse(program: String) -> Expression {
        let tokens = tokenize(program: program)
        let exprs = parse(tokens: tokens)

        return exprs[0]
    }

    func parse(url: URL) -> [Expression] {
        do {
            let evalCode = try String(contentsOf: url)
            let tokens = tokenize(program: evalCode)
            let exprs = parse(tokens: tokens)

            return exprs
        } catch {
            print(error)
        }

        return []
    }

    enum Token : Equatable {
        case open, close, quote, text(String)

        static func == (lhs: Token, rhs: Token) -> Bool {
            switch lhs {
            case .open:
                if case .open = rhs {
                    return true
                }
            case .close:
                if case .close = rhs {
                    return true
                }
            case .quote:
                if case .quote = rhs {
                    return true
                }
            case .text(let text):
                guard case .text(let rhsText) = rhs else {
                    return false
                }

                return text == rhsText
            }

            return false
        }
    }

    enum Mode : Equatable {
        case newLine, code, comment
    }

    func tokenize(program: String) -> [Token] {
        var tokens = [Token]()
        var text = [Character]()
        var mode: Mode = .newLine

        func appendTextAndClean() {
            if text.count != 0 {
                let t = String(text)
                tokens.append(.text(t))
                text.removeAll()
            }
        }

        for character in program {

            switch mode {
            case .newLine, .code:
                if CharacterSet.whitespacesAndNewlines.contains(character: character) {
                    appendTextAndClean()

                    if CharacterSet.newlines.contains(character: character) {
                        mode = .newLine
                    }
                } else if character == "(" {
                    tokens.append(.open)
                } else if character == ")" {
                    appendTextAndClean()
                    tokens.append(.close)
                } else if character == "'" {
                    tokens.append(.quote)
                } else if character == ";" && mode == .newLine {
                    mode = .comment
                    continue
                } else {
                    text.append(character)
                }

                mode = .code
            case .comment:
                if CharacterSet.newlines.contains(character: character) {
                    mode = .newLine
                }
            }
        }

        appendTextAndClean()

        return tokens
    }

    struct ParseState {
        let expression: Expression
        let isQuote: Bool
    }

    func isQuoted(list: [ParseState]) -> Bool {
        if let first = list.first {
            return first.isQuote
        }

        return false
    }

    func parse(tokens: [Token]) -> [Expression] {
        var stack: [[ParseState]] = []

        var currentList = [ParseState]()

        for token in tokens {
            switch token {
            case .open:
                stack.append(currentList)
                currentList = []
            case .close:
                let creadedList: Expression = .list(currentList.map({ (state: ParseState) -> Expression in
                    return state.expression
                }))

                if let topList = stack.popLast() {
                    currentList = topList
                    currentList.append(ParseState(expression: creadedList, isQuote: false))
                }

            case .quote:
                stack.append(currentList)
                currentList = [ParseState(expression: .atom("quote"), isQuote: true)]

            case .text(let text):
                currentList.append(ParseState(expression: .atom(text), isQuote: false))
            }


            if isQuoted(list: currentList) && currentList.count > 1
            {
                let creadedList: Expression = .list(currentList.map({ (state: ParseState) -> Expression in
                    return state.expression
                }))

                if let topList = stack.popLast() {
                    currentList = topList
                    currentList.append(ParseState(expression: creadedList, isQuote: false))
                }
            }
        }

        return currentList.map({ (state: ParseState) -> Expression in
            return state.expression
        })
    }
}
