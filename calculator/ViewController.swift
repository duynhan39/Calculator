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
    
    var zeroLabel : UILabel?
    @IBOutlet var roundedEdgeButtons: [UIButton]!
    @IBOutlet weak var LastRowOfButton: UIStackView!
    @IBOutlet var operatorButtons: [UIButton]!
    @IBOutlet var MathFuncPrimaryButtons: [UIButton]!
    
    @IBOutlet weak var screenOutputLabel: UILabel!
    

    let numberFontToButtonHeight: CGFloat = 0.3
    let operatorFontToButtonHeight: CGFloat = 0.5
    let outputFontToButtonHeight: CGFloat = 1
    
    
    let fontName = "System Font"
    let maxDisplayDigits = 9
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Number Buttons
        for button in roundedEdgeButtons {
            button.layer.cornerRadius = button.frame.height*0.5
            button.titleLabel?.font = UIFont(name: fontName, size: button.frame.height*numberFontToButtonHeight)
            button.setBackgroundColor(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), forState: UIControl.State.highlighted)
        }
        
        // Operator Buttons
        for button in operatorButtons {
            button.titleLabel?.font = UIFont(name: fontName, size: button.frame.height*operatorFontToButtonHeight)
        }
        
        // Math Func Primary Buttons
        for button in MathFuncPrimaryButtons + operatorButtons {
            button.setBackgroundColor(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), forState: UIControl.State.highlighted)
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
    
    func resetInputBuffer() {
        isDisplayInt = true
        screenOutputLabel.text = "0"
    }
    
    @IBAction func AC_CButton(_ sender: Any) {
        resetInputBuffer()
    }
    
    @IBAction func pressDigitButton(_ sender: UIButton) {
        let digit : String = sender.title(for: .normal) ?? "0"
        
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
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumSignificantDigits =  9
        
        var processedText = rawText.replacingOccurrences(of:",", with: "")
        processedText = processedText.replacingOccurrences(of:".", with: "")
        processedText = processedText.replacingOccurrences(of:"-", with: "")
        
        if processedText.first == "0"{
            numberFormatter.maximumSignificantDigits = 8
        }
        
        let number = numberFormatter.number(from: processedText) ?? 0
        
        if processedText.count > maxDisplayDigits {
            numberFormatter.exponentSymbol = "e"
            numberFormatter.positiveFormat = "0.#E+0"
            var stringVal = numberFormatter.string(for: number) ?? "0"
            stringVal = stringVal.components(separatedBy: "e").last ?? "0"
            numberFormatter.positiveFormat = "0." + "#"*(maxDisplayDigits-2-stringVal.count) + "E+0"

        }
        
        return numberFormatter.string(for: number) ?? "0"
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
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
