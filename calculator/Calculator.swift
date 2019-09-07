//
//  Calculator.swift
//  calculator
//
//  Created by Nhan Cao on 8/30/19.
//  Copyright © 2019 Nhan Cao. All rights reserved.
//

import Foundation

class Calculator {
    enum CalOperator: Int {
        case none
        case add
        case sub
        case mul
        case div
        case sqrt
        case rev
    }
    var lhs: Float
    var rhs: Float
    var op: CalOperator
    
    init() {
        lhs = 0
        rhs = 0
        op = .none
    }
    
    func assignLeftValue(of text: String) {
        
    }
}
