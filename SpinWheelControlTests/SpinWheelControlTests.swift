//
//  SpinWheelControlTests.swift
//  SpinWheelControlTests
//
//  Created by Josh Henry on 4/27/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import XCTest
@testable import SpinWheelControl

class SpinWheelControlTests: XCTestCase, SpinWheelControlDataSource {
    
    var numberOfWedges: UInt!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    //Ensure velocity is calculated correctly given a specified spin action's details
    func testVelocity() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let spinWheelControl: SpinWheelControl = SpinWheelControl(frame: frame)
        
        spinWheelControl.startTrackingTime = 0
        spinWheelControl.endTrackingTime = 0.03
        spinWheelControl.previousTouchRadians = -0.491991
        spinWheelControl.currentTouchRadians = 0.993053
        
        XCTAssert(spinWheelControl.velocity == -20.0, "Velocity was not computed correctly.")

        /*
        spinWheelControl.startTrackingTime = 0
        spinWheelControl.endTrackingTime = 0.03
        spinWheelControl.previousTouchRadians = 0.4
        spinWheelControl.currentTouchRadians = 0.10
        
        print(spinWheelControl.velocity)
        
        XCTAssert(spinWheelControl.velocity == 10.0, "Velocity was not computed correctly.")
         */
        
        spinWheelControl.startTrackingTime = 0
        spinWheelControl.endTrackingTime = 0.03
        spinWheelControl.previousTouchRadians = 2.5
        spinWheelControl.currentTouchRadians = 1.7

        XCTAssert(spinWheelControl.velocity == 20.0, "Velocity was not computed correctly.")
    }
    
    
    //Initialize a spin wheel with a given number of wedges and ensure the correct number of labels are created
    func testDrawWedgeLabel() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let spinWheelControl: SpinWheelControl = SpinWheelControl(frame: frame)
        
        spinWheelControl.dataSource = self

        numberOfWedges = 2
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.subviews.count == Int(numberOfWedges), "Not enough labels were drawn given the specified number of wedges in the wheel.")
        
        numberOfWedges = 3
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.subviews.count == Int(numberOfWedges), "Not enough labels were drawn given the specified number of wedges in the wheel.")
        
        numberOfWedges = 8
        spinWheelControl.reloadData()
        
        XCTAssert(spinWheelControl.spinWheelView.subviews.count == Int(numberOfWedges), "Not enough labels were drawn given the specified number of wedges in the wheel.")
        
        numberOfWedges = 0
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.subviews.count == Int(numberOfWedges), "Not enough labels were drawn given the specified number of wedges in the wheel.")
    }
    
    
    //Initialize a spin wheel with a given number of wedges and ensure the correct number of wedges are created
    func testDrawWedge() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let spinWheelControl: SpinWheelControl = SpinWheelControl(frame: frame)
        
        spinWheelControl.dataSource = self
        
        numberOfWedges = 2
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.layer.sublayers!.count == Int(numberOfWedges * 2), "Not enough wedges were drawn given the specified number of wedges in the wheel.")
        
        numberOfWedges = 3
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.layer.sublayers!.count == Int(numberOfWedges * 2), "Not enough wedges were drawn given the specified number of wedges in the wheel.")
        
        numberOfWedges = 8
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.layer.sublayers!.count == Int(numberOfWedges * 2), "Not enough wedges were drawn given the specified number of wedges in the wheel.")
    }
    
    
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return numberOfWedges
    }
}
