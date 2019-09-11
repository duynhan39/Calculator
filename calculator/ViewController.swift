//
//  ViewController.swift
//  calculator
//
//  Created by Nhan Cao on 8/30/19.
//  Copyright © 2019 Nhan Cao. All rights reserved.
//

import UIKit
import Foundation
@IBDesignable

class ViewController: UIViewController {
    
    // View variables
    var zeroLabel : UILabel?
    @IBOutlet var roundedEdgeButtons: [UIButton]!
    @IBOutlet weak var LastRowOfButton: UIStackView!
    @IBOutlet var operatorButtons: [UIButton]!
    @IBOutlet var MathFuncPrimaryButtons: [UIButton]!
    
    @IBOutlet weak var screenOutputLabel: UILabel!
    
    let numberFontToButtonHeight: CGFloat = 0.3
    let operatorFontToButtonHeight: CGFloat = 0.5
    let outputFontToButtonHeight: CGFloat = 1
    
    let numberFormatter = NumberFormatter()
    
    let fontName = "System Font"
    let maxDisplayDigits = 9
    
    // Model Variables
    let calculator = Calculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        numberFormatter.numberStyle = .decimal
        
        resetInputBuffer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Number Buttons
        for button in roundedEdgeButtons {
            button.layer.cornerRadius = button.frame.height*0.5
            button.titleLabel?.font = UIFont(name: fontName, size: button.frame.height*numberFontToButtonHeight)
            button.setBackgroundColor(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), forState: UIControl.State.highlighted)
        }
        
        // Math Func Primary Buttons + Opertator Buttons
        for button in MathFuncPrimaryButtons + operatorButtons {
            button.setBackgroundColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), forState: UIControl.State.highlighted)
        }
        
        // Operator Buttons
        for button in operatorButtons {
            button.titleLabel?.font = UIFont(name: fontName, size: button.frame.height*operatorFontToButtonHeight)
        }
        
        zeroLabel = UILabel(frame: CGRect(x: 0, y: 0, width: LastRowOfButton.frame.height, height: LastRowOfButton.frame.height) )
        zeroLabel?.text = "0"
        zeroLabel?.font = UIFont(name: fontName, size: LastRowOfButton.frame.height*numberFontToButtonHeight)
        zeroLabel?.textAlignment = .center
        zeroLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        LastRowOfButton.addSubview(zeroLabel!)
        
        screenOutputLabel.font = UIFont(name: fontName, size: LastRowOfButton.frame.height*outputFontToButtonHeight)
        screenOutputLabel.text = "0"
        screenOutputLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        screenOutputLabel.adjustsFontSizeToFitWidth = true
    }
    
    var isDisplayInt = true
    var isBuffering = true
    
    func resetInputBuffer() {
        isDisplayInt = true
        isBuffering = true
        screenOutputLabel.text = "0"
        continuousEqual = false
    }
    
    @IBAction func AC_CButton(_ sender: Any) {
        resetInputBuffer()
        calculator.reset()
    }
    
    @IBAction func pressDigitButton(_ sender: UIButton) {
        if continuousEqual {
            calculator.reset()
            continuousEqual = false
        }
        
        let digit : String = sender.title(for: .normal) ?? "0"
        if !isBuffering {
            resetInputBuffer()
            isBuffering = true
        }
        screenOutputLabel.text = appendDigit(to: screenOutputLabel.text ?? "", with: digit)
    }
    
    func appendDigit(to currentText: String, with tail: String) -> String {
        var decimalCount = 1
        if isDisplayInt { decimalCount = 0 }
        let processedText = currentText.replacingOccurrences(of:",", with: "")
        
        if processedText.count >= maxDisplayDigits + decimalCount { return currentText }
        
        if tail == "." {
            if isDisplayInt {
                isDisplayInt = false
                return currentText + tail
            }
            else {
                return currentText
            }
        } else {
            if isDisplayInt {
                return formatDisplayText(of: processedText + tail)
            }
            else {
                return currentText + tail
            }
        }
    }
    
    func formatDisplayText(of rawText: String) -> String {
        
        let number = numberFormatter.number(from: rawText) ?? 0
        numberFormatter.positiveFormat = nil
        
        let processedText = (numberFormatter.string(for: number) ?? "0")

        var leadingZeroCount = 0
        for digit in processedText {
            if digit == "0" { leadingZeroCount += 1 }
            else if digit != "." { break }
        }
        
        numberFormatter.maximumSignificantDigits = maxDisplayDigits - leadingZeroCount
        
        if abs(number as! Double) >= pow(10.0, Double(maxDisplayDigits)) || ( abs(number as! Double) <= pow(0.1, Double(maxDisplayDigits-1)) && number != 0 )
        {
            numberFormatter.exponentSymbol = "e"
            numberFormatter.positiveFormat = "0.#E+0"
            var stringVal = numberFormatter.string(for: number) ?? "0"
            stringVal = stringVal.components(separatedBy: "e").last ?? "0"
            numberFormatter.positiveFormat = "0." + "#"*(maxDisplayDigits-2-stringVal.count) + "E+0"
        }
        
        return (numberFormatter.string(for: number) ?? "0").replacingOccurrences(of:"+", with: "")
    }
    
    @IBAction func pressDualOperator(_ sender: UIButton) {
        continuousEqual = false
        if isBuffering {
            performOperation()
        }
        
        let op = convertOperatorFrom(title: sender.title(for: .normal))
        calculator.assignOperator(with: op)
    }
    
    
    var continuousEqual = false
    @IBAction func pressEqualButton(_ sender: Any) {
        if !calculator.isOpNone() {
            performOperation()
            continuousEqual = true
        }
    }
    
    private func performOperation() {
        if !continuousEqual {
            let rhs = (screenOutputLabel.text ?? "")
            calculator.assignRHS(with: rhs)
        }
        isBuffering = false
        
        var disPlayText: String
        if let result: Double = calculator.performTwoOperandsOperation() {
            disPlayText = formatDisplayText(of: String(result))
        } else {
            disPlayText = "Error"
        }
        
        screenOutputLabel.text = disPlayText
    }
    
    @IBAction func pressSingleOperator(_ sender: UIButton) {
        isBuffering = false
        
        let value = (screenOutputLabel.text ?? "")
        let op = convertOperatorFrom(title: sender.title(for: .normal))
        
        if op == .rev {
            isBuffering = true
            
            let text :String = screenOutputLabel.text!
            if text.count > 1 && text.first ?? " " == "-" {
                let charIndex = text.index(text.startIndex, offsetBy: 1)
                screenOutputLabel.text = String(text[charIndex...])
            } else {
                screenOutputLabel.text = "-"+text
            }
            return
        }
        
        var disPlayText: String
        if let result: Double = calculator.performOneOperandOperation(on: value, with: op) {
            disPlayText = formatDisplayText(of: String(result))
        } else {
            disPlayText = "Error"
        }
        
        screenOutputLabel.text = disPlayText
    }
    
    
    
    private func convertOperatorFrom(title op: String?) -> Calculator.CalOperator {
        switch op {
        case "+":
            return .add
        case "-":
            return .sub
        case "×":
            return .mul
        case "÷":
            return .div
        case "+/-":
            return .rev
        case "1/x":
            return .inv
        case "√":
            return .sqrt
        case "sin":
            return .sin
        case "cos":
            return .cos
        case "tan":
            return .tan
        default:
            return .none
        }
    }
    
    
    
    
    
    
    
    
    
    
    
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

extension String {
    static func * (left: String, right: Int) -> String {
        var result = ""
        if right > 0 {
            for _ in 0..<right {
                result += left
            }
        }
        return result
    }
}
