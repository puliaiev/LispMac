//
//  lisp.swift
//  SwiftLisp
//
//  Created by Sergii Puliaiev on 6/16/17.
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

public class Lisp {

    public init() {}

    public func interpret(program: String) -> String {
        let expr = parser.parse(program: program)
        return String(describing:eval(expression:expr, env:[String: Expression]()))
    }

    let parser = Parser()

    func eval(expression: Expression, env: [String: Expression]) -> Expression {
        switch expression {
        case .atom(let atom):
            return env[atom]!
        case .list(let list):
            if let firstExpression = list.first {
                switch firstExpression {
                case .atom(let atom1):
                    switch atom1 {
                    case "quote":
                        return evalQuote(list: list)
                    case "atom":
                        return evalAtom(list: list, env: env)
                    case "eq":
                        return evalEq(list: list, env: env)
                    case "car":
                        return evalCar(list: list, env: env)
                    case "cdr":
                        return evalCdr(list: list, env: env)
                    case "cons":
                        return evalCons(list: list, env: env)
                    case "cond":
                        return evalCond(list: list, env: env)
                    case "defun":
                        return evalDefun(list: list, env: env)
                    default:
                        var newList = [env[atom1]!]
                        newList += list.dropFirst()
                        return eval(expression: Expression.list(newList), env: env)
                    }
                case .list(let list1):
                    switch list1[0] {
                    case .atom(let atom):
                        switch atom {
                        case "lambda":
                            return evalLambda(list: list, env: env)
                        case "label":
                            return evalLabel(list: list, env: env)
                        default:
                            return Expression.atom(":error")
                        }
                    default:
                        return Expression.atom(":error")
                    }
                }
            }

            return Expression.atom(":error")
        }
    }

    func evalQuote(list: [Expression]) -> Expression {
        return list[1]
    }

    func evalAtom(list: [Expression], env: [String: Expression]) -> Expression {
        let evaluatedAtomsParam = eval(expression: list[1], env: env)

        switch evaluatedAtomsParam {
        case .atom(_):
            return Expression.atom("t")
        case .list(let list):
            return list.count == 0 ? Expression.atom("t") : Expression.list([])
        }
    }

    func evalEq(list: [Expression], env: [String: Expression]) -> Expression {
        let v1 = eval(expression: list[1], env: env)
        let v2 = eval(expression: list[2], env: env)

        if v1 == v2 {
            return Expression.atom("t")
        } else {
            return Expression.list([])
        }
    }

    func evalCar(list: [Expression], env: [String: Expression]) -> Expression {
        let v1 = eval(expression: list[1], env: env)

        switch v1 {
        case .atom(_):
            return Expression.list([])
        case .list(let list):
            return list[0]
        }
    }

    func evalCdr(list: [Expression], env: [String: Expression]) -> Expression {
        let v1 = eval(expression: list[1], env: env)

        switch v1 {
        case .atom(_):
            return Expression.list([])
        case .list(let list):
            return Expression.list(Array(list.dropFirst(1)))
        }
    }

    func evalCons(list: [Expression], env: [String: Expression]) -> Expression {
        let v1 = eval(expression: list[1], env: env)
        let v2 = eval(expression: list[2], env: env)

        switch v2 {
        case .atom(_):
            return Expression.list([v1, v2])
        case .list(let list):
            var listWithFirst = [v1]
            listWithFirst += list
            return Expression.list(listWithFirst)
        }
    }

    func evalCond(list: [Expression], env: [String: Expression]) -> Expression {
        // (cond (p1 e1) (p2 e2) …)
        for expr in list.dropFirst() {
            switch expr {
            case .atom(_):
                continue
            case .list(let list):
                if eval(expression: list[0], env: env) == Expression.atom("t") {
                    return eval(expression: list[1], env: env)
                }
            }
        }

        return Expression.atom(":error")
    }

    struct Lambda {
        let params: [String]
        let body: Expression
    }

    func makeLambda(lambdaExpr: Expression) -> Lambda? {

        func getElement(expr: Expression, index: Int) -> Expression? {
            switch expr {
            case .list(let list):
                return list[index]
            default:
                return nil
            }
        }

        func getList(expr: Expression) -> [Expression]? {
            switch expr {
            case .list(let list):
                return list
            default:
                return nil
            }
        }

        func getAtoms(params: [Expression]) -> [String]? {
            var atoms: [String] = []

            for expr in params {
                switch expr {
                case .atom(let atom):
                    atoms.append(atom)
                default:
                    return nil
                }
            }

            return atoms
        }

        guard let paramsExpr = getElement(expr: lambdaExpr, index: 1) else {
            return nil
        }

        guard let params = getList(expr: paramsExpr) else {
            return nil
        }

        guard let atoms = getAtoms(params: params) else {
            return nil
        }

        guard let body = getElement(expr: lambdaExpr, index: 2) else {
            return nil
        }

        return Lambda(params: atoms, body: body)
    }

    func evalDefun(list: [Expression], env: [String: Expression]) -> Expression {
        let name = list[1]
        let params = list[2]
        let body = list[3]
        let newList = [Expression.atom("label"), name, Expression.list([Expression.atom("lambda"), params, body])]

        if case Expression.atom(let atom) = name {
            var newEnv = env
            newEnv[atom] = Expression.list(newList)

            print(newEnv)

            return name
        }

        return Expression.atom(":error")
    }

    func evalLambda(list: [Expression], env: [String: Expression]) -> Expression {
        let lambda = makeLambda(lambdaExpr: list[0])!

        let arguments = list.dropFirst()

        var newEnv = env

        for (index, argument) in arguments.enumerated() {
            let val = eval(expression: argument, env: env)
            let param = lambda.params[index]
            newEnv[param] = val
        }

        return eval(expression: lambda.body, env: newEnv)
    }

    func evalLabel(list: [Expression], env: [String: Expression]) -> Expression {
        let labelExpr = list[0]

        if case Expression.list(let label) = labelExpr {
            let lambda = label[2]

            if case Expression.atom(let name) = label[1] {
                var newExpression = [lambda]
                newExpression += list.dropFirst()

                var newEnv = env
                newEnv[name] = labelExpr

                return eval(expression: Expression.list(newExpression), env: newEnv)
            }
        }

        return Expression.atom(":error")
    }
}
