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
    
    @objc public func configureWedgeLabel(index: UInt, width: CGFloat, position: CGPoint, orientation:WedgeLabelOrientation, radiansPerWedge: Radians) {
        frame = CGRect (x: 0, y: 0, width: width, height: 30)
        
        self.layer.position = position
        
        if orientation == WedgeLabelOrientation.inOut {
            self.layer.anchorPoint = CGPoint(x: 1.1, y: 0.5)
            self.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(index) + CGFloat.pi + (radiansPerWedge / 2))
        }
        else if orientation == WedgeLabelOrientation.around {
            self.layer.anchorPoint = CGPoint(x: 0.5, y: 4.5)
            self.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(index) + (CGFloat.pi / 2) + (radiansPerWedge / 2))
        }
        
        setDefaultValues()
    }
}

