//
//  SpinWheelWedgeLabel.swift
//  SpinWheelPractice
//
//  Created by Josh Henry on 5/18/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import UIKit

class SpinWheelWedgeLabel: UILabel {
    
    func configureWedgeLabel(index: UInt, width: CGFloat, position: CGPoint, radiansPerWedge: Radians) {
        self.frame = CGRect(x: 0, y: 0, width: width / 2, height: 30)
        self.layer.anchorPoint = CGPoint(x: 1.50, y: 0.5)
        self.layer.position = position
        self.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(index) + CGFloat.pi + (radiansPerWedge / 2))
    }
}
