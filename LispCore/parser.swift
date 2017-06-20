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
        let (expr, _) = parseExpression(characters: program.characters, start: program.characters.startIndex)
        return expr
    }

    func parseExpression(characters: String.CharacterView, start: String.CharacterView.Index) -> (expr: Expression, end: String.CharacterView.Index) {
        if characters[start] == "(" {
            return parseList(characters: characters, startIndex: start)
        } else if characters[start] == "'" {
            let r = parseExpression(characters: characters, start: characters.index(after: start))
            return (Expression.list([Expression.atom("quote"), r.expr]), r.end)
        } else if CharacterSet.whitespacesAndNewlines.contains(character: characters[start]) {
            return parseExpression(characters: characters, start: characters.index(after: start))
        } else {
            return parseAtom(characters: characters, startIndex: start)
        }
    }

    func parseList(characters: String.CharacterView, startIndex: String.CharacterView.Index) -> (expr: Expression, end: String.CharacterView.Index) {
        var index = characters.index(after: startIndex)
        var listValue: [Expression] = []
        while index < characters.endIndex {
            if CharacterSet.whitespacesAndNewlines.contains(character: characters[index]) {
                index = characters.index(after: index)
            } else if characters[index] == ")" {
                break
            } else {
                let ret = parseExpression(characters: characters, start: index)
                listValue.append(ret.expr)
                index = characters.index(after: ret.end)
            }
        }

        return (Expression.list(listValue), index)
    }

    func parseAtom(characters: String.CharacterView, startIndex: String.CharacterView.Index) -> (expr: Expression, end: String.CharacterView.Index) {
        var index = startIndex
        var atom = ""

        while index < characters.endIndex {
            let currentCharacter = characters[index]
            if CharacterSet.whitespacesAndNewlines.contains(character: currentCharacter) || currentCharacter == ")" {
                if atom.characters.count > 0 {
                    return (Expression.atom(atom), characters.index(before: index))
                } else {
                    return (Expression.atom(":error"), index)
                }
            } else {
                atom.append(currentCharacter)
                index = characters.index(after: index)
            }
        }

        return (Expression.atom(atom), characters.index(before: index))
    }
}
