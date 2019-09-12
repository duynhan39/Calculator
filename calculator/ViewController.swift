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
    @IBOutlet var mathFuncPrimaryButtons: [UIButton]!
    @IBOutlet var topRowButtons: [UIButton]!
    
    
    @IBOutlet weak var AC_CButton: UIButton!
    
    @IBOutlet weak var screenOutputLabel: UILabel!
    
    let numberFontToButtonHeight: CGFloat = 0.4
    let mathFuncFontToButtonHeight: CGFloat = 0.3
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
        
        zeroLabel = UILabel()
        LastRowOfButton.addSubview(zeroLabel!)
        
        screenOutputLabel.text = "0"
        screenOutputLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        screenOutputLabel.adjustsFontSizeToFitWidth = true
        
        for button in roundedEdgeButtons {
            button.setBackgroundColor(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), forState: UIControl.State.highlighted)
        }
        
        // Math Func Primary Buttons + Opertator Buttons
        for button in mathFuncPrimaryButtons + operatorButtons {
            button.setBackgroundColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), forState: UIControl.State.highlighted)
            button.setBackgroundColor(color: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), forState: UIControl.State.selected)
            button.setTitleColor(#colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1), for: .selected)
            button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
        
        zeroLabel?.text = "0"
        zeroLabel?.textAlignment = .center
        zeroLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }

    override func viewDidAppear(_ animated: Bool) {
        draw()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil, completion: { _ in
            self.draw()
        })
    }
    
    private func draw() {
        let aButton = mathFuncPrimaryButtons[0]
        screenOutputLabel.font = UIFont(name: fontName, size: aButton.frame.height*outputFontToButtonHeight)
        
        // All Buttons
        var cornerRadius = aButton.frame.height*0.5
        if aButton.frame.height != aButton.frame.width {
            cornerRadius = aButton.frame.height*0.1
        }
        
        for button in roundedEdgeButtons {
            button.layer.cornerRadius = cornerRadius
            button.titleLabel?.font = UIFont(name: fontName, size: button.frame.height*numberFontToButtonHeight)
        }
        
        for button in mathFuncPrimaryButtons + topRowButtons {
            button.titleLabel?.font = UIFont(name: fontName, size: button.frame.height*mathFuncFontToButtonHeight)
        }
        
        // Operator Buttons
        for button in operatorButtons {
            button.titleLabel?.font = UIFont(name: fontName, size: aButton.frame.height*operatorFontToButtonHeight)
        }
        
        zeroLabel?.frame = CGRect(x: 0, y: 0, width: aButton.frame.width, height: aButton.frame.height)
        zeroLabel?.font = UIFont(name: fontName, size: aButton.frame.height*numberFontToButtonHeight)
    }
    
    var isDisplayInt = true
    var isBuffering = true
    var isAC = true {
        didSet {
//            setAC_CLable()
        }
    }
    
    func setAC_CLable() {
        if isAC {
            AC_CButton.titleLabel?.text = "AC"
        } else {
            AC_CButton.titleLabel?.text = "C"
        }
    }
    
    func resetInputBuffer() {
        isDisplayInt = true
        isBuffering = true
        continuousEqual = false
        screenOutputLabel.text = "0"
    }
    
    @IBAction func AC_CButton(_ sender: Any) {
        resetInputBuffer()
        if isAC {
            calculator.reset()
            prevButton?.isSelected = false
            prevButton = nil
        } else {
            prevButton!.isSelected = true
            isAC = true
        }
    }
    
    @IBAction func pressDigitButton(_ sender: UIButton) {
        if isAC {
            isAC = false
        }
        
        prevButton?.isSelected = false
        
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
    
    var prevButton: UIButton? = nil
    @IBAction func pressDualOperator(_ sender: UIButton) {
        
        prevButton?.isSelected = false
        prevButton = sender
        sender.isSelected = true
        
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
        
        prevButton?.isSelected = false
        
        prevButton?.isSelected = false
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
