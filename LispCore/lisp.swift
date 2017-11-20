//
//  lisp.swift
//  SwiftLisp
//
//  Created by Sergii Puliaiev on 6/16/17.
//  Copyright © 2017 Sergii Puliaiev. All rights reserved.
//

import Foundation

typealias Environment = [String: Expression]

enum LispError: Error {
    case runtime
    case unknown
}

public class Lisp {

    public init() {
        try? loadDefaultLibrary()
    }

    func loadDefaultLibrary() throws {
        guard let file = Bundle(for: Lisp.self).url(forResource: "eval", withExtension: "lisp") else {
            return
        }

        let expressions = parser.parse(url: file)

        for expr in expressions {
            let _ = try eval(expression: expr, env: Environment())
        }
    }

    var globalEnv: Environment = Environment()

    public func interpret(program: String) throws -> String {
        let expr = parser.parse(program: program)
        let evalExpr = try eval(expression: expr, env: Environment())

        return String(describing: evalExpr)
    }

    let parser = Parser()
}

extension Lisp {
    func eval(expression: Expression, env: Environment) throws -> Expression {
        switch expression {
        case .atom(let atom):
            guard let expr = env[atom] ?? globalEnv[atom] else {
                throw LispError.runtime
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
                        return try evalAtom(list: list, env: env)
                    case "eq":
                        return try evalEq(list: list, env: env)
                    case "car":
                        return try evalCar(list: list, env: env)
                    case "cdr":
                        return try evalCdr(list: list, env: env)
                    case "cons":
                        return try evalCons(list: list, env: env)
                    case "cond":
                        return try evalCond(list: list, env: env)
                    case "defun":
                        return try evalDefun(list: list, env: env)
                    default:
                        return try evalFuncCall(list: list, env: env)
                    }
                case .list(let list1):
                    switch list1[0] {
                    case .atom(let atom):
                        switch atom {
                        case "lambda":
                            return try evalLambda(list: list, env: env)
                        case "label":
                            return try evalLabel(list: list, env: env)
                        default:
                            throw LispError.runtime
                        }
                    default:
                        throw LispError.runtime
                    }
                }
            }

            throw LispError.runtime
        }
    }

    func evalQuote(list: [Expression], env: Environment) -> Expression {
        return list[1]
    }

    func evalAtom(list: [Expression], env: Environment) throws -> Expression {
        let evaluatedAtomsParam = try eval(expression: list[1], env: env)

        switch evaluatedAtomsParam {
        case .atom(_):
            return Expression.atom("t")
        case .list(let list):
            return list.count == 0 ? Expression.atom("t") : Expression.list([])
        }
    }

    func evalEq(list: [Expression], env: Environment) throws -> Expression {
        let v1 = try eval(expression: list[1], env: env)
        let v2 = try eval(expression: list[2], env: env)

        if v1 == v2 {
            return Expression.atom("t")
        } else {
            return Expression.list([])
        }
    }

    func evalCar(list: [Expression], env: Environment) throws -> Expression {
        let v1 = try eval(expression: list[1], env: env)

        switch v1 {
        case .atom(_):
            throw LispError.runtime
        case .list(let list):
            return list.first ?? Expression.list([])
        }
    }

    func evalCdr(list: [Expression], env: Environment) throws -> Expression {
        let v1 = try eval(expression: list[1], env: env)

        switch v1 {
        case .atom(_):
            return Expression.list([])
        case .list(let list):
            return Expression.list(Array(list.dropFirst(1)))
        }
    }

    func evalCons(list: [Expression], env: Environment) throws -> Expression {
        let v1 = try eval(expression: list[1], env: env)
        let v2 = try eval(expression: list[2], env: env)

        switch v2 {
        case .atom(_):
            return Expression.list([v1, v2])
        case .list(let list):
            var listWithFirst = [v1]
            listWithFirst += list
            return Expression.list(listWithFirst)
        }
    }

    func evalCond(list: [Expression], env: Environment) throws -> Expression {
        for expr in list.dropFirst() {
            switch expr {
            case .atom(_):
                continue
            case .list(let list):
                let evalExpression = try eval(expression: list[0], env: env)
                if evalExpression == Expression.atom("t") {
                    return try eval(expression: list[1], env: env)
                }
            }
        }

        throw LispError.runtime
    }

    func evalLambda(list: [Expression], env: Environment) throws -> Expression {
        guard case Expression.list(let lambda) = list[0] else {
            throw LispError.runtime
        }

        guard case Expression.list(let params) = lambda[1] else {
            throw LispError.runtime
        }

        let body = lambda[2]

        let arguments = list.dropFirst()

        var newEnv = env

        for (index, argument) in arguments.enumerated() {
            let val = try eval(expression: argument, env: env)
            if case Expression.atom(let param) = params[index] {
                newEnv[param] = val
            }
        }

        return try eval(expression: body, env: newEnv)
    }

    func evalDefun(list: [Expression], env: Environment) throws -> Expression {
        let name = list[1]
        let params = list[2]
        let body = list[3]

        let newLambda = Expression.list([Expression.atom("lambda"), params, body])

        if case Expression.atom(let atom) = name {
            globalEnv[atom] = newLambda

            return name
        }

        throw LispError.runtime
    }

    func evalLabel(list: [Expression], env: Environment) throws -> Expression {
        let labelExpr = list[0]

        if case Expression.list(let label) = labelExpr {
            let lambda = label[2]

            if case Expression.atom(let name) = label[1] {
                var newExpression = [lambda]
                newExpression += list.dropFirst()

                globalEnv[name] = labelExpr

                return try eval(expression: Expression.list(newExpression), env: env)
            }
        }

        throw LispError.runtime
    }

    func evalFuncCall(list: [Expression], env: Environment) throws -> Expression {
        guard case .atom(let funcName) = list[0] else {
            throw LispError.runtime
        }

        do {
            let regex = try NSRegularExpression(pattern: "c([ad]*)r")
            if let _ = regex.firstMatch(in: funcName, range: NSRange(funcName.startIndex..., in: funcName)) {

                var newFunc = list[1]

                for symbol in funcName.reversed() {
                    switch symbol {
                    case "d":
                        newFunc = Expression.list([Expression.atom("cdr"), newFunc])
                    case "a":
                        newFunc = Expression.list([Expression.atom("car"), newFunc])
                    default:
                        break
                    }
                }

                return try eval(expression: newFunc, env: env)
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            throw LispError.runtime
        }


        guard let funcDef = env[funcName] ?? globalEnv[funcName] else {
            throw LispError.runtime
        }
        
        var newList = [funcDef]
        newList += list.dropFirst()
        
        return try eval(expression: Expression.list(newList), env: env)
    }
}
