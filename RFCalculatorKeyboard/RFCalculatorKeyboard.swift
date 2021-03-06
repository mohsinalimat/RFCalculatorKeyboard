//
//  RFCalculatorKeyboard.swift
//  RFCalculatorKeyboard
//
//  Created by Guilherme Moura on 8/15/15.
//  Copyright (c) 2015 Reefactor, Inc. All rights reserved.
//

import UIKit

public protocol RFCalculatorDelegate: class {
    func calculator(calculator: RFCalculatorKeyboard, didChangeValue value: String)
}

enum CalculatorKey: Int {
    case Zero = 1
    case One
    case Two
    case Three
    case Four
    case Five
    case Six
    case Seven
    case Eight
    case Nine
    case Decimal
    case Clear
    case Delete
    case Multiply
    case Divide
    case Subtract
    case Add
    case Equal
}

public class RFCalculatorKeyboard: UIView {
    public weak var delegate: RFCalculatorDelegate?
    public var numbersBackgroundColor = UIColor(white: 0.97, alpha: 1.0) {
        didSet {
            adjustLayout()
        }
    }
    public var numbersTextColor = UIColor.blackColor() {
        didSet {
            adjustLayout()
        }
    }
    public var operationsBackgroundColor = UIColor(white: 0.75, alpha: 1.0) {
        didSet {
            adjustLayout()
        }
    }
    public var operationsTextColor = UIColor.whiteColor() {
        didSet {
            adjustLayout()
        }
    }
    public var equalBackgroundColor = UIColor(red:0.96, green:0.5, blue:0, alpha:1) {
        didSet {
            adjustLayout()
        }
    }
    public var equalTextColor = UIColor.whiteColor() {
        didSet {
            adjustLayout()
        }
    }
    
    public var showDecimal = false {
        didSet {
            processor.automaticDecimal = !showDecimal
            adjustLayout()
        }
    }
    
    var view: UIView!
    private var processor = RFCalculatorProcessor()
    
    @IBOutlet weak var zeroDistanceConstraint: NSLayoutConstraint!
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    private func loadXib() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        adjustLayout()
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CalculatorKeyboard", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        return view
    }
    
    private func adjustLayout() {
        let view = viewWithTag(CalculatorKey.Decimal.rawValue)
        if let decimal = view {
            let width = UIScreen.mainScreen().bounds.width / 4.0
            zeroDistanceConstraint.constant = showDecimal ? width + 2.0 : 1.0
            layoutIfNeeded()
        }
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let image = UIImage(named: "RF_black_background", inBundle: bundle, compatibleWithTraitCollection: nil)
        for var i = 1; i <= CalculatorKey.Decimal.rawValue; i++ {
            if let button = self.view.viewWithTag(i) as? UIButton {
                button.setBackgroundImage(image, forState: .Normal)
                button.tintColor = numbersBackgroundColor
                button.setTitleColor(numbersTextColor, forState: .Normal)
            }
        }
        
        for var i = CalculatorKey.Clear.rawValue; i <= CalculatorKey.Add.rawValue; i++ {
            if let button = self.view.viewWithTag(i) as? UIButton {
                button.setBackgroundImage(image, forState: .Normal)
                button.tintColor = operationsBackgroundColor
                button.setTitleColor(operationsTextColor, forState: .Normal)
            }
        }
        
        if let button = self.view.viewWithTag(CalculatorKey.Equal.rawValue) as? UIButton {
            button.setBackgroundImage(image, forState: .Normal)
            button.tintColor = equalBackgroundColor
            button.setTitleColor(equalTextColor, forState: .Normal)
        }
    }
    
    @IBAction func buttonPressed(sender: UIButton) {
        let key = CalculatorKey(rawValue: sender.tag)!
        switch (sender.tag) {
        case (CalculatorKey.Zero.rawValue)...(CalculatorKey.Nine.rawValue):
            var output = processor.storeOperand(sender.tag-1)
            delegate?.calculator(self, didChangeValue: output)
        case CalculatorKey.Decimal.rawValue:
            var output = processor.addDecimal()
            delegate?.calculator(self, didChangeValue: output)
        case CalculatorKey.Clear.rawValue:
            var output = processor.clearAll()
            delegate?.calculator(self, didChangeValue: output)
        case CalculatorKey.Delete.rawValue:
            var output = processor.deleteLastDigit()
            delegate?.calculator(self, didChangeValue: output)
        case (CalculatorKey.Multiply.rawValue)...(CalculatorKey.Add.rawValue):
            var output = processor.storeOperator(sender.tag)
            delegate?.calculator(self, didChangeValue: output)
        case CalculatorKey.Equal.rawValue:
            var output = processor.computeFinalValue()
            delegate?.calculator(self, didChangeValue: output)
            break
        default:
            break
        }
    }
}
