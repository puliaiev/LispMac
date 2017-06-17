//
//  parser.swift
//  LispMac
//
//  Created by Sergii Puliaiev on 6/17/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import Foundation

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
        } else {
            return parseAtom(characters: characters, startIndex: start)
        }
    }

    func parseList(characters: String.CharacterView, startIndex: String.CharacterView.Index) -> (expr: Expression, end: String.CharacterView.Index) {
        var index = characters.index(after: startIndex)
        var listValue: [Expression] = []
        while index < characters.endIndex {
            if characters[index] == " " {
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
            if currentCharacter == " " || currentCharacter == ")"  {
                return (Expression.atom(atom), characters.index(before: index))
            } else {
                atom.append(currentCharacter)
                index = characters.index(after: index)
            }
        }

        return (Expression.atom(atom), characters.index(before: index))
    }
}
