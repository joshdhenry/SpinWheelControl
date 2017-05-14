//
//  SpinWheelControlDataSource.swift
//  SpinWheelControl
//
//  Created by Josh Henry on 4/29/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import Foundation

@objc public protocol SpinWheelControlDataSource : NSObjectProtocol {
    
    //Return the number of wedges in the specified SpinWheelControl.
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt
}
