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
    
    @IBOutlet var roundedEdgeButtons: [UIButton]!
    
    var zeroLabel : UILabel?
    
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var LastRowOfButton: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fontToButtonHeight: CGFloat = 0.3
    
        for button in roundedEdgeButtons {
            button.layer.cornerRadius = button.frame.height*0.5
            button.titleLabel?.font = .systemFont(ofSize: button.frame.height*fontToButtonHeight)
            
            button.setBackgroundColor(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), forState: UIControl.State.highlighted)
        }
        
        zeroLabel = UILabel(frame: CGRect(x: zeroButton.frame.minX, y: zeroButton.frame.minY, width: zeroButton.frame.height, height: zeroButton.frame.height) )
        zeroLabel?.text = "0"
        zeroLabel?.font = .systemFont(ofSize: zeroButton.frame.height*fontToButtonHeight)
        zeroLabel?.textAlignment = .center
        zeroLabel?.textColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        
        LastRowOfButton.addSubview(zeroLabel!)
    }
    
    @IBAction func pressButton(_ sender: UIButton) {
        let digit = sender.title(for: .normal) ?? "0"
        print(digit)
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

