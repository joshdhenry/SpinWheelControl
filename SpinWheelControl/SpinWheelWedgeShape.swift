//
//  SpinWheelWedgeShape.swift
//  SpinWheelPractice
//
//  Created by Josh Henry on 5/18/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import UIKit

open class SpinWheelWedgeShape: CAShapeLayer {
    
    @objc public var borderSize: WedgeBorderSize = WedgeBorderSize.none {
        didSet {
            self.lineWidth = CGFloat(borderSize.rawValue)
        }
    }
    
    
    //If values aren't manually set, then set the default values here.
    private func setDefaultValues() {
        self.lineWidth = CGFloat(borderSize.rawValue)
    }
    
    
    @objc public func configureWedgeShape(index: UInt, radius: CGFloat, position: CGPoint, degreesPerWedge: Degrees) {
        setDefaultValues()
        
        self.path = createWedgeShapeBezierPath(index: index, radius: radius, position: position, degreesPerWedge: degreesPerWedge).cgPath
    }
    
    
    //Create the path for this wedge shape.
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
