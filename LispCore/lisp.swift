//
//  lisp.swift
//  SwiftLisp
//
//  Created by Sergii Puliaiev on 6/16/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import Foundation

typealias Environment = [String: Expression]

public class Lisp {

    public init() {}

    var globalEnv: Environment = Environment()

    public func interpret(program: String) -> String {
        let expr = parser.parse(program: program)
        let evalExpr = eval(expression: expr, env: Environment())

        return String(describing: evalExpr)
    }

    let parser = Parser()
}

extension Lisp {
    func eval(expression: Expression, env: Environment) -> Expression {
        switch expression {
        case .atom(let atom):
            guard let expr = env[atom] ?? globalEnv[atom] else {
                return Expression.atom(":error")
            }

            return expr
        case .list(let list):
            if let firstExpression = list.first {
                switch firstExpression {
                case .atom(let atom1):
                    switch atom1 {
                    case "quote":
                        return evalQuote(list: list, env: env)
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
                        return evalFuncCall(list: list, env: env)
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

    func evalQuote(list: [Expression], env: Environment) -> Expression {
        return list[1]
    }

    func evalAtom(list: [Expression], env: Environment) -> Expression {
        let evaluatedAtomsParam = eval(expression: list[1], env: env)

        switch evaluatedAtomsParam {
        case .atom(_):
            return Expression.atom("t")
        case .list(let list):
            return list.count == 0 ? Expression.atom("t") : Expression.list([])
        }
    }

    func evalEq(list: [Expression], env: Environment) -> Expression {
        let v1 = eval(expression: list[1], env: env)
        let v2 = eval(expression: list[2], env: env)

        if v1 == v2 {
            return Expression.atom("t")
        } else {
            return Expression.list([])
        }
    }

    func evalCar(list: [Expression], env: Environment) -> Expression {
        let v1 = eval(expression: list[1], env: env)

        switch v1 {
        case .atom(_):
            return Expression.list([])
        case .list(let list):
            return list[0]
        }
    }

    func evalCdr(list: [Expression], env: Environment) -> Expression {
        let v1 = eval(expression: list[1], env: env)

        switch v1 {
        case .atom(_):
            return Expression.list([])
        case .list(let list):
            return Expression.list(Array(list.dropFirst(1)))
        }
    }

    func evalCons(list: [Expression], env: Environment) -> Expression {
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

    func evalCond(list: [Expression], env: Environment) -> Expression {
        for expr in list.dropFirst() {
            switch expr {
            case .atom(_):
                continue
            case .list(let list):
                let evalExpression = eval(expression: list[0], env: env)
                if evalExpression == Expression.atom("t") {
                    return eval(expression: list[1], env: env)
                }
            }
        }

        return Expression.atom(":error")
    }

    func evalLambda(list: [Expression], env: Environment) -> Expression {
        guard case Expression.list(let lambda) = list[0] else {
            return Expression.atom(":error")
        }

        guard case Expression.list(let params) = lambda[1] else {
            return Expression.atom(":error")
        }

        let body = lambda[2]

        let arguments = list.dropFirst()

        var newEnv = env

        for (index, argument) in arguments.enumerated() {
            let val = eval(expression: argument, env: env)
            if case Expression.atom(let param) = params[index] {
                newEnv[param] = val
            }
        }

        return eval(expression: body, env: newEnv)
    }

    func evalDefun(list: [Expression], env: Environment) -> Expression {
        let name = list[1]
        let params = list[2]
        let body = list[3]

        let newLambda = Expression.list([Expression.atom("lambda"), params, body])

        if case Expression.atom(let atom) = name {
            globalEnv[atom] = newLambda

            return name
        }

        return Expression.atom(":error")
    }

    func evalLabel(list: [Expression], env: Environment) -> Expression {
        let labelExpr = list[0]

        if case Expression.list(let label) = labelExpr {
            let lambda = label[2]

            if case Expression.atom(let name) = label[1] {
                var newExpression = [lambda]
                newExpression += list.dropFirst()

                globalEnv[name] = labelExpr

                return eval(expression: Expression.list(newExpression), env: env)
            }
        }

        return Expression.atom(":error")
    }

    func evalFuncCall(list: [Expression], env: Environment) -> Expression {
        guard case .atom(let funcName) = list[0] else {
            return Expression.atom(":error")
        }

        guard let funcDef = env[funcName] ?? globalEnv[funcName] else {
            return Expression.atom(":error")
        }
        
        var newList = [funcDef]
        newList += list.dropFirst()
        
        return eval(expression: Expression.list(newList), env: env)
    }
}
