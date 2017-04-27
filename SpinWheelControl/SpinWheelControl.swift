//
//  SpinWheelControl.swift
//  SpinWheelControl
//
//  Created by Josh Henry on 4/27/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import UIKit

public class SpinWheelControl: UIControl {
    
    var spinWheelView: UIView!
    var currentRotation: CGFloat = 0
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.drawWheel()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func drawWheel() {
        spinWheelView = UIView(frame: self.bounds)
        
        self.backgroundColor = UIColor.cyan
        
        let center = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        
        let radius:CGFloat = 100.0
        
        let numOfWedges = 8
        let wedgeSize = 360 / numOfWedges
        
        for wedgeNum in 1...numOfWedges {
            let newWedge = CAShapeLayer()
            newWedge.fillColor = UIColor.yellow.cgColor
            newWedge.strokeColor = UIColor.black.cgColor
            newWedge.lineWidth = 3.0;
            let newWedgePath = UIBezierPath()
            newWedgePath.move(to: center)
            let startAngle = Double(wedgeNum * wedgeSize) * Double.pi / 180
            let endAngle = Double((wedgeNum + 1) * wedgeSize) * Double.pi / 180
            newWedgePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
            newWedgePath.close()
            newWedge.path = newWedgePath.cgPath;
            
            self.spinWheelView.layer.addSublayer(newWedge)
        }
        
        //Disable user interaction on spinWheelView so that tracking can be detected on the underlying UIControl
        self.spinWheelView.isUserInteractionEnabled = false
        self.addSubview(self.spinWheelView)
    }
    
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        NSLog("Tracking")
        currentRotation += 10
        self.spinWheelView.transform = CGAffineTransform(rotationAngle: currentRotation)
        return true
    }
    
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        NSLog("Tracking2")
        print("TOUCH - ")
        print(touch)
        print(CACurrentMediaTime())
        
        currentRotation += 1
        self.spinWheelView.transform = CGAffineTransform(rotationAngle: currentRotation)
        return true
    }
    
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        NSLog("Tracking3")
    }
    
    
    func beginDeceleration() {
        
    }
    
}
