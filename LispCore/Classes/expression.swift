//
//  expression.swift
//  LispMac
//
//  Created by Sergii Puliaiev on 6/17/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import Foundation

enum Expression {
    case atom(String)
    case list([Expression])
}

extension Expression : CustomStringConvertible {
    var description: String {
        switch self {
        case .atom(let atom):
            return "\(atom)"
        case .list(let expressions):
            var description = "("
            for (index, expression) in expressions.enumerated() {
                if index == expressions.count - 1 {
                    description += "\(expression)"
                } else {
                    description += "\(expression) "
                }
            }
            description += ")"
            return description
        }
    }
}

extension Expression : Equatable {
    static func == (lhs: Expression, rhs: Expression) -> Bool {
        switch lhs {
        case .atom(let lhsAtom):
            switch rhs {
            case .atom(let rhsAtom):
                return lhsAtom == rhsAtom
            case .list(_):
                return false
            }
        case .list(let lhsList):
            switch rhs {
            case .atom(_):
                return false
            case .list(let rhsList):
                return lhsList == rhsList
            }
        }
    }
}
