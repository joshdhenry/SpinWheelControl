//
//  SpinWheelWedgeLabel.swift
//  SpinWheelPractice
//
//  Created by Josh Henry on 5/18/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import UIKit

open class SpinWheelWedgeLabel: UILabel {
    
    private func setDefaultValues() {
        self.textColor = UIColor.white
        self.shadowColor = UIColor.black
        self.adjustsFontSizeToFitWidth = true
        self.textAlignment = .center
    }
    
    public func configureWedgeLabel(index: UInt, width: CGFloat, position: CGPoint, radiansPerWedge: Radians) {
        self.frame = CGRect(x: 0, y: 0, width: width, height: 30)
        self.layer.anchorPoint = CGPoint(x: 1.1, y: 0.5)
        self.layer.position = position
        self.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(index) + CGFloat.pi + (radiansPerWedge / 2))
        
        setDefaultValues()
    }
}
