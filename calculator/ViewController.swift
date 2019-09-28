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
    private var zeroLabel : UILabel?
    @IBOutlet private var roundedEdgeButtons: [UIButton]!
    @IBOutlet private weak var LastRowOfButton: UIStackView!
    @IBOutlet private var operatorButtons: [UIButton]!
    @IBOutlet private var mathFuncPrimaryButtons: [UIButton]!
    @IBOutlet private var topRowButtons: [UIButton]!
    
    @IBOutlet private weak var AC_CButton: UIButton!
    
    @IBOutlet private weak var screenOutputLabel: UILabel!
    
    private let numberFontToButtonHeight: CGFloat = 0.4
    private let mathFuncFontToButtonHeight: CGFloat = 0.3
    private let operatorFontToButtonHeight: CGFloat = 0.5
    private let outputFontToButtonHeight: CGFloat = 1
    
    private let numberFormatter = NumberFormatter()
    
    private let fontName = "System Font"
    private let maxDisplayDigits = 9
    
    // Model Variables
    private let calculator = Calculator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resetInputBuffer()
        numberFormatter.numberStyle = .decimal
        
        screenOutputLabel.text = "0"
        screenOutputLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        screenOutputLabel.adjustsFontSizeToFitWidth = true
        
        for button in roundedEdgeButtons {
            button.setBackgroundColor(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), forState: UIControl.State.highlighted)
        }
    
        for button in mathFuncPrimaryButtons + operatorButtons {
            button.setBackgroundColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), forState: UIControl.State.highlighted)
            button.setBackgroundColor(color: #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1), forState: UIControl.State.selected)
            button.setTitleColor(#colorLiteral(red: 1, green: 0.5781051517, blue: 0, alpha: 1), for: .selected)
            button.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        }
        
        zeroLabel = UILabel()
        zeroLabel?.text = "0"
        zeroLabel?.textAlignment = .center
        zeroLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        LastRowOfButton.addSubview(zeroLabel!)
        
        AC_CButton.setTitle("C", for: .selected)
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
    
    private var isDisplayInt = true
    private var isBuffering = true
    private var isSelectingOperator = false
    private var isAC = true {
        didSet { AC_CButton.isSelected = !isAC }
    }
    
//    func setAC_CLable() {
//        AC_CButton.isSelected = !isAC
//    }
    
    private func resetInputBuffer() {
        isDisplayInt = true
        isBuffering = true
        continuousEqual = false
        screenOutputLabel.text = "0"
    }
    
    @IBAction func AC_CButton(_ sender: Any) {
        resetInputBuffer()
        if isAC {
            calculator.reset()
            setPrevOperatorButton(to: nil)
        } else {
            setPrevOperatorButton(to: true)
            isAC = true
        }
    }
    
    @IBAction func pressDigitButton(_ sender: UIButton) {
        isAC = false
        
        setPrevOperatorButton(to: false)
        
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
    
    private func appendDigit(to currentText: String, with tail: String) -> String {
        var decimalCount = 1
        if isDisplayInt { decimalCount = 0 }
        let processedText = currentText.replacingOccurrences(of:",", with: "")
        
        if processedText.count >= maxDisplayDigits + decimalCount { return currentText }
        
        if tail == "." {
            if isDisplayInt {
                isDisplayInt = false
                return currentText + tail
            } else { return currentText }
        } else {
            if isDisplayInt { return formatDisplayText(of: processedText + tail) }
            else { return currentText + tail }
        }
    }
    
    private func formatDisplayText(of rawText: String) -> String {
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
    
    private var prevOperatorButton: UIButton? = nil
    
    @IBAction func pressDualOperator(_ sender: UIButton) {
        prevOperatorButton?.isSelected = false
        prevOperatorButton = sender
        
        continuousEqual = false
        if !isSelectingOperator && isBuffering { performOperation() }
        
        setPrevOperatorButton(to: true)
        
        let op = convertOperatorFrom(title: sender.title(for: .normal))
        calculator.assignOperator(with: op)
    }

    private var continuousEqual = false
    @IBAction func pressEqualButton(_ sender: Any) {
        setPrevOperatorButton(to: nil)
        
        if !calculator.isOpNone() {
            performOperation()
            continuousEqual = true
        }
        
        isBuffering = false
    }
    
    private func performOperation() {
        if !continuousEqual {
            let rhs = (screenOutputLabel.text ?? "")
            calculator.assignRHS(with: rhs)
        }
        
        var disPlayText: String
        if let result: Double = calculator.performTwoOperandsOperation() { disPlayText = formatDisplayText(of: String(result)) }
        else { disPlayText = "Error" }
        
        screenOutputLabel.text = disPlayText
        isBuffering = false
    }
    
    @IBAction func pressSingleOperator(_ sender: UIButton) {
        let value = (screenOutputLabel.text ?? "")
        if value == "Error" { return }
        
        let op = convertOperatorFrom(title: sender.title(for: .normal))
        if op == .rev {
            if value.count > 1 && value.first ?? " " == "-" {
                let charIndex = value.index(value.startIndex, offsetBy: 1)
                screenOutputLabel.text = String(value[charIndex...])
            } else { screenOutputLabel.text = "-"+value }
            return
        }
    
        var disPlayText: String
        if let result: Double = calculator.performOneOperandOperation(on: value, with: op) { disPlayText = formatDisplayText(of: String(result)) }
        else { disPlayText = "Error" }
        
        screenOutputLabel.text = disPlayText
        isBuffering = false
    }
    
    private func setPrevOperatorButton(to state: Any?) {
        if state == nil {
            prevOperatorButton?.isSelected = false
            prevOperatorButton = nil
        } else if state is Bool { prevOperatorButton?.isSelected = state as! Bool }
        
        isSelectingOperator = (state as? Bool) ?? false
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
