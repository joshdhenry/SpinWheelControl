//
//  SpinWheelControl.swift
//  SpinWheelControl
//
//  Created by Josh Henry on 4/27/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//

import UIKit

public enum SpinWheelStatus {
    case Idle, Decelerating, Snapping
}

open class SpinWheelControl: UIControl {
    
    //MARK: Properties
    weak public var dataSource: SpinWheelControlDataSource?
    public var delegate: SpinWheelControlDelegate?
    
    static let kMinimumRadiansForSpin: CGFloat = 0.1
    static let kMinDistanceFromCenter: CGFloat = 30.0
    static let kMaxVelocity: CGFloat = 20
    static let kDecelerationVelocityMultiplier: CGFloat = 0.98 //The deceleration multiplier is not to be set past 0.99 in order to avoid issues
    static let kSpeedToSnap: CGFloat = 0.1
    static let kSnapRadiansProximity: CGFloat = 0.001
    static let kWedgeSnapVelocityMultiplier: CGFloat = 10.0
    static let kZoomZoneThreshold = 1.5
    
    //A circle = 360 degrees = 2 * pi radians
    let circleRadians = 2 * CGFloat.pi
    
    var spinWheelView: UIView!
    
    private var numberOfWedges: UInt!
    private var radiansPerWedge: CGFloat!
    
    var decelerationDisplayLink: CADisplayLink? = nil
    var snapDisplayLink: CADisplayLink? = nil
    
    var startTrackingTime: CFTimeInterval!
    var endTrackingTime: CFTimeInterval!
    
    var previousTouchRadians: CGFloat!
    var currentTouchRadians: CGFloat!
    var startTouchRadians: CGFloat!
    var currentlyDetectingTap: Bool!
    
    var currentStatus: SpinWheelStatus = .Idle
    
    var currentDecelerationVelocity: CGFloat!
    
    var snapDestinationRadians: CGFloat!
    var snapIncrementRadians: CGFloat!
    
    var selectedIndex: Int!
    
    let colorPalette: [UIColor] = [UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.darkGray, UIColor.green, UIColor.magenta, UIColor.red, UIColor.orange]
    
    //MARK: Computed Properties
    var wedgeDegreesSize: CGFloat {
        return 360 / CGFloat(numberOfWedges)
    }
    
    var radius: CGFloat {
        return self.frame.width / 2
    }
    
    var currentRadians: CGFloat {
        return atan2(self.spinWheelView.transform.b, self.spinWheelView.transform.a)
    }
    
    // TODO : Not even sure if this is necessary?
    var snappingRadiansForWheel: CGFloat {
        return CGFloat.pi / 2
    }
    
    var radiansToDestinationSlice: CGFloat {
        return snapDestinationRadians - currentRadians
    }
    
    
    //The velocity of the spinwheel
    var velocity: CGFloat {
        var computedVelocity: CGFloat = 0
        
        //If the wheel was actually spun, calculate the new velocity
        if endTrackingTime != startTrackingTime &&
            abs(previousTouchRadians - currentTouchRadians) >= SpinWheelControl.kMinimumRadiansForSpin {
            computedVelocity = (previousTouchRadians - currentTouchRadians) / CGFloat(endTrackingTime - startTrackingTime)
        }
        
        //If the velocity is beyond the maximum allowed velocity, throttle it
        if computedVelocity > SpinWheelControl.kMaxVelocity {
            computedVelocity = SpinWheelControl.kMaxVelocity
        }
        else if computedVelocity < -SpinWheelControl.kMaxVelocity {
            computedVelocity = -SpinWheelControl.kMaxVelocity
        }
        
        return computedVelocity
    }
    
    
    //MARK: Initialization Methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.drawWheel()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Methods
    //TODO : I need to remove the colored wedges since this only removes the labels.
    public func clear() {
        for subview in spinWheelView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    
    public func drawWheel() {
        NSLog("Drawing wheel...")
        
        spinWheelView = UIView(frame: self.bounds)
        
        self.backgroundColor = UIColor.cyan
        
        guard self.dataSource?.numberOfWedgesInSpinWheel(spinWheel: self) != nil else {
            return
        }
        numberOfWedges = self.dataSource?.numberOfWedgesInSpinWheel(spinWheel: self)
        
        guard numberOfWedges >= 2 else {
            return
        }
        
        radiansPerWedge = circleRadians / CGFloat(numberOfWedges)
        
        //Draw each individual wedge
        for wedgeNumber in 1...numberOfWedges {
            drawWedge(wedgeNumber: wedgeNumber)
        }
        
        //Draw each individual label
        for wedgeNumber in 1...numberOfWedges {
            drawWedgeLabel(wedgeNumber: wedgeNumber)
        }
        self.spinWheelView.isUserInteractionEnabled = false
        self.addSubview(self.spinWheelView)
        
        checkForWedgesInZoomZone()
    }
    
    
    func drawWedge(wedgeNumber: UInt) {
        let newWedge = CAShapeLayer()
        newWedge.fillColor = colorPalette[Int(wedgeNumber) - 1].cgColor
        newWedge.strokeColor = UIColor.black.cgColor
        newWedge.lineWidth = 3.0
        
        let newWedgePath = UIBezierPath()
        newWedgePath.move(to: center)
        let startRadians: CGFloat = CGFloat(wedgeNumber) * wedgeDegreesSize * CGFloat.pi / 180
        print(startRadians)
        print(CGFloat(wedgeNumber) * 360 / CGFloat(numberOfWedges) * circleRadians / 360)
        print("---")
        let endRadians: CGFloat = CGFloat(wedgeNumber + 1) * wedgeDegreesSize * CGFloat.pi / 180
        
        newWedgePath.addArc(withCenter: center, radius: radius, startAngle: startRadians, endAngle: endRadians, clockwise: true)
        newWedgePath.close()
        newWedge.path = newWedgePath.cgPath
        
        //newWedge.transform = newWedge.transform.rotated(by: radiansPerWedge * CGFloat(wedgeNum) + snappingRadiansForWheel)
        
        spinWheelView.layer.addSublayer(newWedge)
    }
    
    func drawWedgeLabel(wedgeNumber: UInt) {
        let wedgeLabelFrame: CGRect = CGRect(x: 0, y: 0, width: 150, height: 30)
        let wedgeLabel: UILabel = UILabel(frame: wedgeLabelFrame)
        wedgeLabel.layer.anchorPoint = CGPoint(x: 1.0, y: 0.5)
        wedgeLabel.layer.position = CGPoint(x: self.spinWheelView.bounds.size.width / 2 - self.spinWheelView.frame.origin.x, y: self.spinWheelView.bounds.size.height / 2 - self.spinWheelView.frame.origin.y)
        
        wedgeLabel.transform = CGAffineTransform(rotationAngle: radiansPerWedge * CGFloat(wedgeNumber) + snappingRadiansForWheel)
        wedgeLabel.backgroundColor = colorPalette[Int(wedgeNumber) - 1]
        wedgeLabel.layer.borderColor = UIColor.black.cgColor
        wedgeLabel.layer.borderWidth = 3.0
        wedgeLabel.textColor = UIColor.white
        wedgeLabel.text = "Label #" + String(wedgeNumber)
        spinWheelView.addSubview(wedgeLabel)
    }
    
    
    func didEndRotationOnWedgeAtIndex(index: UInt) {
        selectedIndex = Int(index)
        delegate?.spinWheelDidEndDecelerating?(spinWheel: self)
        self.sendActions(for: .valueChanged)
    }
    
    
    //User began touching/dragging the UIControl
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        NSLog("Begin Tracking...")
        
        switch currentStatus {
        case SpinWheelStatus.Idle:
            currentlyDetectingTap = true
        case SpinWheelStatus.Decelerating:
            endDeceleration()
            endSnap()
        case SpinWheelStatus.Snapping:
            endSnap()
        }
        
        let touchPoint: CGPoint = touch.location(in: self)
        
        if distanceFromCenter(point: touchPoint) < SpinWheelControl.kMinDistanceFromCenter {
            return false
        }
        
        startTrackingTime = CACurrentMediaTime()
        endTrackingTime = startTrackingTime
        
        startTouchRadians = radiansForTouch(touch: touch)
        currentTouchRadians = startTouchRadians
        previousTouchRadians = startTouchRadians
        
        return true
    }
    
    
    //User is in the middle of dragging the UIControl
    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        NSLog("Continue Tracking...")
        
        currentlyDetectingTap = false
        
        startTrackingTime = endTrackingTime
        endTrackingTime = CACurrentMediaTime()
        
        let touchPoint: CGPoint = touch.location(in: self)
        let distanceFromCenterOfSpinWheel: CGFloat = distanceFromCenter(point: touchPoint)
        
        if distanceFromCenterOfSpinWheel < SpinWheelControl.kMinDistanceFromCenter {
            return true
        }
        
        previousTouchRadians = currentTouchRadians
        currentTouchRadians = radiansForTouch(touch: touch)
        let touchRadiansDifference: CGFloat = currentTouchRadians - previousTouchRadians
        
        self.spinWheelView.transform = self.spinWheelView.transform.rotated(by: touchRadiansDifference)
        
        delegate?.spinWheelDidRotateByRadians?(radians: touchRadiansDifference)
        
        checkForWedgesInZoomZone()
        
        return true
    }
    
    
    //User ended touching/dragging the UIControl
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        NSLog("End Tracking...")
        
        let tapCount = touch?.tapCount != nil ? (touch?.tapCount)! : 0
        //If the user just tapped, move to that wedge
        if currentStatus == .Idle &&
            tapCount > 0 &&
            currentlyDetectingTap {
            didReceiveTapAtRadian(radian: radiansForTouch(touch: touch!))
        }
            //Else decelerate
        else {
            beginDeceleration()
        }
    }
    
    
    //After user has lifted their finger from dragging, begin the deceleration
    func beginDeceleration() {
        NSLog("Beginning deceleration...")
        
        currentDecelerationVelocity = velocity
        
        //If the wheel was spun, begin deceleration
        if currentDecelerationVelocity != 0 {
            currentStatus = .Decelerating
            
            decelerationDisplayLink?.invalidate()
            decelerationDisplayLink = CADisplayLink(target: self, selector: #selector(SpinWheelControl.decelerationStep))
            decelerationDisplayLink?.preferredFramesPerSecond = 60
            decelerationDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
            //Else snap to the nearest wedge.  No deceleration necessary.
        else {
            snapToNearestWedge()
        }
    }
    
    
    //Deceleration step run for each frame of decelerationDisplayLink
    func decelerationStep() {
        NSLog("Deceleration step...")
        
        let newVelocity: CGFloat = currentDecelerationVelocity * SpinWheelControl.kDecelerationVelocityMultiplier
        //TODO - Why 60?  Should this be a constant?
        let radiansToRotate: CGFloat = currentDecelerationVelocity / 60
        
        //If the spinwheel has slowed down to under the minimum speed, end the deceleration
        if newVelocity <= SpinWheelControl.kSpeedToSnap &&
            newVelocity >= -SpinWheelControl.kSpeedToSnap {
            endDeceleration()
        }
            //else continue decelerating the SpinWheel
        else {
            currentDecelerationVelocity = newVelocity
            self.spinWheelView.transform = self.spinWheelView.transform.rotated(by: -radiansToRotate)
            
            delegate?.spinWheelDidRotateByRadians?(radians: -radiansToRotate)
            
            checkForWedgesInZoomZone()
        }
    }
    
    
    //End decelerating the spinwheel
    func endDeceleration() {
        NSLog("End Decelerating...")
        
        decelerationDisplayLink?.invalidate()
        snapToNearestWedge()
    }
    
    
    //Snap to the nearest wedge
    func snapToNearestWedge() {
        NSLog("Snap to nearest wedge...")
        
        currentStatus = .Snapping
        
        let nearestWedge: Int = Int(round(currentRadians / radiansPerWedge))
        selectWedgeAtIndex(index: nearestWedge, animated: true)
    }
    
    
    func snapStep() {
        NSLog("Snap step...")
        
        //Sine, Cosine and Tangent are each a ratio of sides of a right angled triangle
        //Arc tangent (atan2) calculates the angles of a right triangle (tangent = Opposite / Adjacent)
        //The sin is ratio of the length of the side that is opposite that angle to the length of the longest side of the triangle (the hypotenuse) (sin = Opposite / Hypotenuse)
        //The cosine is (cosine = Adjacent / Hypotenuse)
        let difference = atan2(sin(radiansToDestinationSlice), cos(radiansToDestinationSlice))
        
        //If the spin wheel is turned close enough to the destination it is snapping to, end snapping
        if abs(difference) <= SpinWheelControl.kSnapRadiansProximity {
            endSnap()
        }
            //else continue snapping to the nearest wedge
        else {
            let newPositionRadians = currentRadians + snapIncrementRadians
            self.spinWheelView.transform = CGAffineTransform(rotationAngle: newPositionRadians)
            
            delegate?.spinWheelDidRotateByRadians?(radians: newPositionRadians)
            
            checkForWedgesInZoomZone()
        }
    }
    
    
    //End snapping
    func endSnap() {
        NSLog("End snap...")
        
        let abc: CGFloat = -(CGFloat.pi - currentRadians)
        print("---")
        print(abc / radiansPerWedge + CGFloat(numberOfWedges))
        print(-(CGFloat.pi - currentRadians) / radiansPerWedge + CGFloat(numberOfWedges))
        print("---")
        
        let indexOldWay: UInt = UInt(lroundf(Float(abc / radiansPerWedge + CGFloat(numberOfWedges)))) % numberOfWedges
        //TODO: Not sure the modulus is even needed here?  IT IS.  PUT IT BACK IN !!!!!!
        var index = -(CGFloat.pi - currentRadians) / radiansPerWedge + CGFloat(numberOfWedges)
        index = index.rounded(FloatingPointRoundingRule.awayFromZero)
        print("^^^")
        print(indexOldWay)
        //print(Float(abc / radiansPerWedge + CGFloat(numberOfWedges)))
        print(index)
        //print(-(CGFloat.pi - currentRadians) / radiansPerWedge + CGFloat(numberOfWedges))
        print("%%%%")
        
        didEndRotationOnWedgeAtIndex(index: UInt(index))
        
        snapDisplayLink?.invalidate()
        currentStatus = .Idle
    }
    
    
    //Return the radians at the touch point. Return values range from -pi to pi
    func radiansForTouch(touch: UITouch) -> CGFloat {
        let touchPoint: CGPoint = touch.location(in: self)
        let dx: CGFloat = touchPoint.x - self.spinWheelView.center.x
        let dy: CGFloat = touchPoint.y - self.spinWheelView.center.y
        
        return atan2(dy, dx)
    }
    
    
    func didReceiveTapAtRadian(radian: CGFloat) {
        NSLog("Did receive tap at radian...")
    }
    
    
    func selectWedgeAtIndex(index: Int, animated: Bool) {
        NSLog("Select wedge at index...")
        
        snapDestinationRadians = CGFloat(index) * radiansPerWedge
        
        //Determine which way to rotate based on what side of the spin wheel is currently being pointed to. Basically, find the shortest path to the destination.
        if radiansToDestinationSlice > CGFloat.pi {
            snapDestinationRadians = snapDestinationRadians - circleRadians
        }
        else if radiansToDestinationSlice < -CGFloat.pi {
            snapDestinationRadians = snapDestinationRadians + circleRadians
        }
        
        if currentRadians != snapDestinationRadians {
            snapIncrementRadians = radiansToDestinationSlice / SpinWheelControl.kWedgeSnapVelocityMultiplier
        }
        else {
            return
        }
        
        currentStatus = .Snapping
        
        snapDisplayLink?.invalidate()
        snapDisplayLink = CADisplayLink(target: self, selector: #selector(snapStep))
        snapDisplayLink?.preferredFramesPerSecond = 60
        snapDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    
    func checkForWedgesInZoomZone() {
    }
    
    
    //Distance of a point from the center of the spinwheel
    func distanceFromCenter(point: CGPoint) -> CGFloat {
        let center: CGPoint = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        let dx: CGFloat = point.x - center.x
        let dy: CGFloat = point.y - center.y
        
        return sqrt(dx * dx + dy * dy)
    }
    
    
    public func reloadData() {
        clear()
        drawWheel()
    }
}
