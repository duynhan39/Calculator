//
//  Calculator.swift
//  calculator
//
//  Created by Nhan Cao on 8/30/19.
//  Copyright © 2019 Nhan Cao. All rights reserved.
//

import Foundation

class Calculator {
    enum CalOperator: String {
        case none = ""
        case add = "+"
        case sub = "-"
        case mul = "*"
        case div = "/"
        case sqrt = "sqrt"
        case inv = "1.0/"
        case rev = "0-"
        case sin = "sin"
        case cos = "cos"
        case tan = "tan"
        
    }
//    var operands = [Float]()
//    var operators = [CalOperator]()
    
    var lhs = ""
    var rhs = ""
    var op = CalOperator.none
    
    func reset() {
        lhs = ""
        rhs = ""
        op = CalOperator.none
        
        print("RESET")
    }
    
    private func filterStringNumber(of str: String) -> String {
        var filteredStr = str.replacingOccurrences(of:",", with: "")
        if (filteredStr.last ?? " ") == "." {
            filteredStr.replacingOccurrences(of:".", with: "")
        }
        return filteredStr
    }
    
//    func assignLHS(with number: String) {
//        lhs = filterStringNumber(of: number)
//    }
    
    func assignRHS(with number: String) {
        rhs = filterStringNumber(of: number)
    }
    
    func assignOperator(with thisOp: CalOperator) {
        op = thisOp
    }
    
    private func evaluate(expression str: String) -> Double? {
        let mathExpression: String = str
        let exp: NSExpression = NSExpression(format: mathExpression)
        
        if str.first ?? " " != "E" {
            let result: Double? = exp.expressionValue(with: nil, context: nil) as! Double?
            
            print("EX: \(mathExpression)")
            print(result)
            
            if result?.isNormal ?? false {
                return result
            }
        }
        return nil
        
    }
    
    func performTwoOperandsOperation() -> Double? {
        let mathExpression = lhs + op.rawValue + rhs
        let result = evaluate(expression: mathExpression)
        if result == nil {
            lhs = "Error"
        } else {
            lhs = String(result!)
        }
        return result
    }
    
    func performOneOperandOperation(on rawText: String, with op: CalOperator) -> Double? {
        if rawText.first ?? " " != "E" {
            
            let number = filterStringNumber(of: rawText)
            
            switch op {
            case .sin:
                return sin(Double(number) ?? 0)
            case .cos:
                return cos(Double(number) ?? 0)
            case .tan:
                return tan(Double(number) ?? 0)
            default:
                let mathExpression = "\(op.rawValue)(\(number))"
                return evaluate(expression: mathExpression)
            }
        }
        return nil
    }
}
