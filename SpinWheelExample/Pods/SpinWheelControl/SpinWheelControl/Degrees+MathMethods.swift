//
//  Degrees+MathMethods.swift
//  SpinWheelPractice
//
//  Created by Josh Henry on 5/19/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import Foundation
import UIKit

extension Degrees {
    
    var toRadians: Radians {
        return self * CGFloat.pi / 180
    }
}
