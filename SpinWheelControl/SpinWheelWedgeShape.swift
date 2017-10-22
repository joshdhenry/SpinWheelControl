//
//  SpinWheelWedgeShape.swift
//  SpinWheelPractice
//
//  Created by Josh Henry on 5/18/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import UIKit

open class SpinWheelWedgeShape: CAShapeLayer {
    
    private func setDefaultValues() {
        self.strokeColor = UIColor.white.cgColor
        self.lineWidth = 3.0
    }
    
    
    @objc public func configureWedgeShape(index: UInt, radius: CGFloat, position: CGPoint, degreesPerWedge: Degrees) {
        self.path = createWedgeShapeBezierPath(index: index, radius: radius, position: position, degreesPerWedge: degreesPerWedge).cgPath
        
        setDefaultValues()
    }
    
    
    private func createWedgeShapeBezierPath(index: UInt, radius: CGFloat, position: CGPoint, degreesPerWedge: Degrees) -> UIBezierPath {
        let newWedgePath: UIBezierPath = UIBezierPath()
        newWedgePath.move(to: position)
        
        let startRadians: Radians = CGFloat(index) * degreesPerWedge * CGFloat.pi / 180
        let endRadians: Radians = CGFloat(index + 1) * degreesPerWedge * CGFloat.pi / 180
        
        newWedgePath.addArc(withCenter: position, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        newWedgePath.close()
        
        return newWedgePath
    }
}
