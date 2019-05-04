//
//  SpinWheelWedgeShape.swift
//  SpinWheelPractice
//
//  Created by Josh Henry on 5/18/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import UIKit

open class SpinWheelWedgeShape: CAShapeLayer {
    
    @objc public var borderSize: WedgeBorderSize = WedgeBorderSize.none
    
    private func setDefaultValues() {
        switch borderSize {
        case WedgeBorderSize.none:
            self.lineWidth = 0
        case WedgeBorderSize.small:
            self.lineWidth = 1
        case WedgeBorderSize.medium:
            self.lineWidth = 2
        case WedgeBorderSize.large:
            self.lineWidth = 3
        }
    }
    
    
    @objc public func configureWedgeShape(index: UInt, radius: CGFloat, position: CGPoint, degreesPerWedge: Degrees) {
        self.path = createWedgeShapeBezierPath(index: index, radius: radius, position: position, degreesPerWedge: degreesPerWedge).cgPath
        
        setDefaultValues()
    }
    
    
    private func createWedgeShapeBezierPath(index: UInt, radius: CGFloat, position: CGPoint, degreesPerWedge: Degrees) -> UIBezierPath {
        let newWedgePath: UIBezierPath = UIBezierPath()
        newWedgePath.move(to: position)
        
        let startRadians: Radians = CGFloat(index) * degreesPerWedge.toRadians
        let endRadians: Radians = CGFloat(index + 1) * degreesPerWedge.toRadians
        
        newWedgePath.addArc(withCenter: position, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        newWedgePath.close()
        return newWedgePath
    }
}
