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
        
        switch orientation {
        case .around:
            //Position times 2 is the total size of the control. 0.015 is the sweet spot to determine label position for any size.
            let yDistanceFromCenter: CGFloat = (position.x * 2) * 0.015
            self.layer.anchorPoint = CGPoint(x: 0.5, y: yDistanceFromCenter)
            self.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(index) + (CGFloat.pi / 2) + (radiansPerWedge / 2))
        case .outIn:
            self.layer.anchorPoint = CGPoint(x: 1.1, y: 0.5)
            self.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(index) + CGFloat.pi + (radiansPerWedge / 2))
        case .inOut:
            self.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            self.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(index) + (radiansPerWedge / 2))
        }
        
        setDefaultValues()
    }
}

