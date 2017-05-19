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
    func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
        let wedge = SpinWheelWedge()
        return wedge
    }

    
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

        
        spinWheelControl.startTrackingTime = 0
        spinWheelControl.endTrackingTime = 0.03
        spinWheelControl.previousTouchRadians = 0.4
        spinWheelControl.currentTouchRadians = 0.10
        
        XCTAssert(round(spinWheelControl.velocity) == 10.0, "Velocity was not computed correctly.")
        
        
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
        print("HEY")
        print(spinWheelControl.spinWheelView.layer.sublayers!.count)
        XCTAssert(spinWheelControl.spinWheelView.layer.sublayers!.count == Int(numberOfWedges), "Not enough wedges were drawn given the specified number of wedges in the wheel.")
        
        numberOfWedges = 3
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.layer.sublayers!.count == Int(numberOfWedges), "Not enough wedges were drawn given the specified number of wedges in the wheel.")
        
        numberOfWedges = 8
        spinWheelControl.reloadData()
        XCTAssert(spinWheelControl.spinWheelView.layer.sublayers!.count == Int(numberOfWedges), "Not enough wedges were drawn given the specified number of wedges in the wheel.")
    }
    
    
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return numberOfWedges
    }
    
    
    func testBeginDeceleration() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let spinWheelControl: SpinWheelControl = SpinWheelControl(frame: frame)
        
        spinWheelControl.startTrackingTime = 0
        spinWheelControl.endTrackingTime = 0.03
        spinWheelControl.previousTouchRadians = 2.5
        spinWheelControl.currentTouchRadians = 1.7
        
        spinWheelControl.beginDeceleration()
        XCTAssertEqual(spinWheelControl.currentStatus, .decelerating, "The beginDeceleration method did not change the spin wheel's current status to 'decelerating'.")
    }
    
    
    func testDistanceFromCenter() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let spinWheelControl: SpinWheelControl = SpinWheelControl(frame: frame)
        
        var point:CGPoint = CGPoint(x: 100, y: 100)
        var distFromCenterPoint = spinWheelControl.distanceFromCenter(point: point)
        
        XCTAssert(distFromCenterPoint == 0, "Distance from center was not calculated correctly.")
        
        point = CGPoint(x: 50, y: 50)
        distFromCenterPoint = spinWheelControl.distanceFromCenter(point: point)
        XCTAssert(round(distFromCenterPoint) == 71, "Distance from center was not calculated correctly.")
    }
    
    
    func testReloadData() {
        let frame: CGRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let spinWheelControl: SpinWheelControl = SpinWheelControl(frame: frame)
        
        spinWheelControl.dataSource = self
        
        numberOfWedges = 2
        
        XCTAssertEqual(spinWheelControl.spinWheelView.subviews.count, 0, "The reloadData method did not correctly reload the data for the spin wheel control.")
        
        spinWheelControl.reloadData()
        XCTAssertEqual(spinWheelControl.spinWheelView.subviews.count, 2, "The reloadData method did not correctly reload the data for the spin wheel control.")
        
        numberOfWedges = 8
        spinWheelControl.reloadData()
        XCTAssertEqual(spinWheelControl.spinWheelView.subviews.count, 8, "The reloadData method did not correctly reload the data for the spin wheel control.")
    }
}
