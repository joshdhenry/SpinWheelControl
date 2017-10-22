//
//  SpinWheelControl.swift
//  SpinWheelControl
//
//  Created by Josh Henry on 4/27/17.
//  Copyright © 2017 Big Smash Software. All rights reserved.
//
//Trigonometry is used extensively in SpinWheel Control. Here is a quick refresher.
//Sine, Cosine and Tangent are each a ratio of sides of a right angled triangle
//Arc tangent (atan2) calculates the angles of a right triangle (tangent = Opposite / Adjacent)
//The sin is ratio of the length of the side that is opposite that angle to the length of the longest side of the triangle (the hypotenuse) (sin = Opposite / Hypotenuse)
//The cosine is (cosine = Adjacent / Hypotenuse)

import UIKit

public typealias Degrees = CGFloat
public typealias Radians = CGFloat
typealias Velocity = CGFloat

public enum SpinWheelStatus {
    case idle, decelerating, snapping
}

public enum SpinWheelDirection {
    case up, right, down, left
    
    var radiansValue: Radians {
        switch self {
        case .up:
            return Radians.pi / 2
        case .right:
            return 0
        case .down:
            return -(Radians.pi / 2)
        case .left:
            return Radians.pi
        }
    }
    
    var degreesValue: Degrees {
        switch self {
        case .up:
            return 90
        case .right:
            return 0
        case .down:
            return 270
        case .left:
            return 180
        }
    }
}

@IBDesignable
open class SpinWheelControl: UIControl {
    
    //MARK: Properties
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    
    @IBInspectable var snapOrientation: CGFloat = SpinWheelDirection.up.degreesValue {
        didSet {
            snappingPositionRadians = snapOrientation.toRadians
        }
    }
    
    
    @objc weak public var dataSource: SpinWheelControlDataSource?
    @objc public var delegate: SpinWheelControlDelegate?
    
    @objc static let kMinimumRadiansForSpin: Radians = 0.1
    @objc static let kMinDistanceFromCenter: CGFloat = 30.0
    @objc static let kMaxVelocity: Velocity = 20
    @objc static let kDecelerationVelocityMultiplier: CGFloat = 0.98 //The deceleration multiplier is not to be set past 0.99 in order to avoid issues
    @objc static let kSpeedToSnap: CGFloat = 0.1
    @objc static let kSnapRadiansProximity: Radians = 0.001
    @objc static let kWedgeSnapVelocityMultiplier: CGFloat = 10.0
    @objc static let kZoomZoneThreshold = 1.5
    @objc static let kPreferredFramesPerSecond: Int = 60
    
    //A circle = 360 degrees = 2 * pi radians
    @objc let kCircleRadians: Radians = 2 * CGFloat.pi
    
    @objc public var spinWheelView: UIView!
    
    private var numberOfWedges: UInt!
    private var radiansPerWedge: CGFloat!
    
    @objc var decelerationDisplayLink: CADisplayLink? = nil
    @objc var snapDisplayLink: CADisplayLink? = nil
    
    var startTrackingTime: CFTimeInterval!
    var endTrackingTime: CFTimeInterval!
    
    var previousTouchRadians: Radians!
    var currentTouchRadians: Radians!
    var startTouchRadians: Radians!
    var currentlyDetectingTap: Bool!
    
    var currentStatus: SpinWheelStatus = .idle
    
    var currentDecelerationVelocity: Velocity!
    
    @objc var snappingPositionRadians: Radians = SpinWheelDirection.up.radiansValue
    var snapDestinationRadians: Radians!
    var snapIncrementRadians: Radians!
    
    @objc public var selectedIndex: Int = 0
    
    //MARK: Computed Properties
    @objc var spinWheelCenter: CGPoint {
        return convert(center, from: superview)
    }
    
    @objc var diameter: CGFloat {
        return min(self.spinWheelView.frame.width, self.spinWheelView.frame.height)
    }
    
    @objc var degreesPerWedge: Degrees {
        return 360 / CGFloat(numberOfWedges)
    }
    
    //The radius of the spin wheel's circle
    @objc var radius: CGFloat {
        return diameter / 2
    }
    
    //How far the wheel is turned from its default position
    @objc var currentRadians: Radians {
        return atan2(self.spinWheelView.transform.b, self.spinWheelView.transform.a)
    }
    
    //How many radians there are to snapDestinationRadians
    @objc var radiansToDestinationSlice: Radians {
        return snapDestinationRadians - currentRadians
    }
    
    //The velocity of the spinwheel
    @objc var velocity: Velocity {
        var computedVelocity: Velocity = 0
        
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
    
    public init(frame: CGRect, snapOrientation: SpinWheelDirection) {
        super.init(frame: frame)
        
        self.drawWheel()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.drawWheel()
    }
    
    
    //MARK: Methods
    //Clear the SpinWheelControl from the screen
    @objc public func clear() {
        for subview in spinWheelView.subviews {
            subview.removeFromSuperview()
        }
        guard let sublayers = spinWheelView.layer.sublayers else {
            return
        }
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
    }
    
    
    //Draw the spinWheelView
    @objc public func drawWheel() {
        spinWheelView = UIView(frame: self.bounds)
        
        guard self.dataSource?.numberOfWedgesInSpinWheel(spinWheel: self) != nil else {
            return
        }
        numberOfWedges = self.dataSource?.numberOfWedgesInSpinWheel(spinWheel: self)
        
        guard numberOfWedges >= 2 else {
            return
        }
        
        radiansPerWedge = kCircleRadians / CGFloat(numberOfWedges)
        
        guard let source = self.dataSource else {
            return
        }
        
        for wedgeNumber in 0..<numberOfWedges {
            let wedge: SpinWheelWedge = source.wedgeForSliceAtIndex(index: wedgeNumber)
            
            //Wedge shape
            wedge.shape.configureWedgeShape(index: wedgeNumber, radius: radius, position: spinWheelCenter, degreesPerWedge: degreesPerWedge)
            wedge.layer.addSublayer(wedge.shape)
            
            //Wedge label
            wedge.label.configureWedgeLabel(index: wedgeNumber, width: radius * 0.9, position: spinWheelCenter, radiansPerWedge: radiansPerWedge)
            wedge.addSubview(wedge.label)
            
            //Add the shape and label to the spinWheelView
            spinWheelView.addSubview(wedge)
        }
        
        self.spinWheelView.isUserInteractionEnabled = false
        
        //Rotate the wheel to put the first wedge at the top
        self.spinWheelView.transform = CGAffineTransform(rotationAngle: -(snappingPositionRadians) - (radiansPerWedge / 2))
        
        self.addSubview(self.spinWheelView)
    }
    
    
    //When the SpinWheelControl ends rotation, trigger the UIControl's valueChanged to reflect the newly selected value.
    @objc func didEndRotationOnWedgeAtIndex(index: UInt) {
        selectedIndex = Int(index)
        delegate?.spinWheelDidEndDecelerating?(spinWheel: self)
        self.sendActions(for: .valueChanged)
    }
    
    
    //User began touching/dragging the UIControl
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        switch currentStatus {
        case SpinWheelStatus.idle:
            currentlyDetectingTap = true
        case SpinWheelStatus.decelerating:
            endDeceleration()
            endSnap()
        case SpinWheelStatus.snapping:
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
        let touchRadiansDifference: Radians = currentTouchRadians - previousTouchRadians
        
        self.spinWheelView.transform = self.spinWheelView.transform.rotated(by: touchRadiansDifference)
        
        delegate?.spinWheelDidRotateByRadians?(radians: touchRadiansDifference)
        
        return true
    }
    
    
    //User ended touching/dragging the UIControl
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        let tapCount = touch?.tapCount != nil ? (touch?.tapCount)! : 0
        //TODO: Implement tap to move to wedge
        //If the user just tapped, move to that wedge
        if currentStatus == .idle &&
            tapCount > 0 &&
            currentlyDetectingTap {}
            //Else decelerate
        else {
            beginDeceleration()
        }
    }
    
    
    //After user has lifted their finger from dragging, begin the deceleration
    @objc func beginDeceleration() {
        currentDecelerationVelocity = velocity
        
        //If the wheel was spun, begin deceleration
        if currentDecelerationVelocity != 0 {
            currentStatus = .decelerating
            
            decelerationDisplayLink?.invalidate()
            decelerationDisplayLink = CADisplayLink(target: self, selector: #selector(SpinWheelControl.decelerationStep))
            if #available(iOS 10.0, *) {
                decelerationDisplayLink?.preferredFramesPerSecond = SpinWheelControl.kPreferredFramesPerSecond
            } else {
                // Fallback on earlier versions
            }
            decelerationDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
            //Else snap to the nearest wedge.  No deceleration necessary.
        else {
            snapToNearestWedge()
        }
    }
    
    
    //Deceleration step run for each frame of decelerationDisplayLink
    @objc func decelerationStep() {
        let newVelocity: Velocity = currentDecelerationVelocity * SpinWheelControl.kDecelerationVelocityMultiplier
        let radiansToRotate: Radians = currentDecelerationVelocity / CGFloat(SpinWheelControl.kPreferredFramesPerSecond)
        
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
        }
    }
    
    
    //End decelerating the spinwheel
    @objc func endDeceleration() {
        decelerationDisplayLink?.invalidate()
        snapToNearestWedge()
    }
    
    
    //Snap to the nearest wedge
    @objc func snapToNearestWedge() {
        currentStatus = .snapping
        
        let nearestWedge: Int = Int(round(((currentRadians + (radiansPerWedge / 2)) + snappingPositionRadians) / radiansPerWedge))
        
        selectWedgeAtIndexOffset(index: nearestWedge, animated: true)
    }
    
    
    @objc func snapStep() {
        let difference: Radians = atan2(sin(radiansToDestinationSlice), cos(radiansToDestinationSlice))
        
        //If the spin wheel is turned close enough to the destination it is snapping to, end snapping
        if abs(difference) <= SpinWheelControl.kSnapRadiansProximity {
            endSnap()
        }
            //else continue snapping to the nearest wedge
        else {
            let newPositionRadians: Radians = currentRadians + snapIncrementRadians
            self.spinWheelView.transform = CGAffineTransform(rotationAngle: newPositionRadians)
            
            delegate?.spinWheelDidRotateByRadians?(radians: newPositionRadians)
        }
    }
    
    
    //End snapping
    @objc func endSnap() {
        //snappingPositionRadians is the default snapping position (in this case, up)
        //currentRadians in this case is where in the wheel it is currently snapped
        //Distance of zero wedge from the default snap position (up)
        var indexSnapped: Radians = (-(snappingPositionRadians) - currentRadians - (radiansPerWedge / 2))
        
        //Number of wedges from the zero wedge to the default snap position (up)
        indexSnapped = indexSnapped / radiansPerWedge + CGFloat(numberOfWedges)
        
        indexSnapped = indexSnapped.rounded(FloatingPointRoundingRule.toNearestOrAwayFromZero)
        indexSnapped = indexSnapped.truncatingRemainder(dividingBy: CGFloat(numberOfWedges))
        
        didEndRotationOnWedgeAtIndex(index: UInt(indexSnapped))
        
        snapDisplayLink?.invalidate()
        currentStatus = .idle
    }
    
    
    //Return the radians at the touch point. Return values range from -pi to pi
    @objc func radiansForTouch(touch: UITouch) -> Radians {
        let touchPoint: CGPoint = touch.location(in: self)
        let dx: CGFloat = touchPoint.x - self.spinWheelView.center.x
        let dy: CGFloat = touchPoint.y - self.spinWheelView.center.y
        
        return atan2(dy, dx)
    }
    
    
    //Select a wedge with an index offset relative to 0 position. May be positive or negative.
    @objc func selectWedgeAtIndexOffset(index: Int, animated: Bool) {
        snapDestinationRadians = -(snappingPositionRadians) + (CGFloat(index) * radiansPerWedge) - (radiansPerWedge / 2)
        
        if currentRadians != snapDestinationRadians {
            snapIncrementRadians = radiansToDestinationSlice / SpinWheelControl.kWedgeSnapVelocityMultiplier
        }
        else {
            return
        }
        
        currentStatus = .snapping
        
        snapDisplayLink?.invalidate()
        snapDisplayLink = CADisplayLink(target: self, selector: #selector(snapStep))
        if #available(iOS 10.0, *) {
            snapDisplayLink?.preferredFramesPerSecond = SpinWheelControl.kPreferredFramesPerSecond
        } else {
            // Fallback on earlier versions
        }
        snapDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }
    
    
    //Distance of a point from the center of the spinwheel
    @objc func distanceFromCenter(point: CGPoint) -> CGFloat {
        let dx: CGFloat = point.x - spinWheelCenter.x
        let dy: CGFloat = point.y - spinWheelCenter.y
        
        return sqrt(dx * dx + dy * dy)
    }
    
    
    //Clear all views and redraw the spin wheel
    @objc public func reloadData() {
        clear()
        drawWheel()
    }
}
