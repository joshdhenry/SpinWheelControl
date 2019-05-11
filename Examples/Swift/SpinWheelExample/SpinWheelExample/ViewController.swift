//
//  ViewController.swift
//  SpinWheelPractice
//
//  Created by Josh Henry on 3/31/19.
//  Copyright © 2019 Big Smash Software. All rights reserved.
//

import UIKit
import SpinWheelControl

class ViewController: UIViewController, SpinWheelControlDataSource, SpinWheelControlDelegate {
    
    let colorPalette: [UIColor] = [UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.darkGray, UIColor.green, UIColor.magenta, UIColor.red, UIColor.orange, UIColor.black, UIColor.gray, UIColor.lightGray, UIColor.purple, UIColor.yellow, UIColor.white]
    
    var spinWheelControl:SpinWheelControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 0, y: 50, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        spinWheelControl = SpinWheelControl(frame: frame, snapOrientation: .down, wedgeLabelOrientation: WedgeLabelOrientation.around)
        
        //Make sure to add the subview before running reloadData(), so it spins around the correct axis.
        self.view.addSubview(spinWheelControl)
        
        spinWheelControl.addTarget(self, action: #selector(spinWheelDidChangeValue), for: UIControl.Event.valueChanged)
        
        spinWheelControl.dataSource = self
        spinWheelControl.delegate = self
        
        spinWheelControl.wedgeBorderColor = UIColor.black

        spinWheelControl.reloadData()
    }
    
    
    func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt {
        return 5
    }
    
    
    func wedgeForSliceAtIndex(index: UInt) -> SpinWheelWedge {
        let wedge = SpinWheelWedge()
        
        wedge.shape.fillColor = colorPalette[Int(index)].cgColor
        wedge.label.text = "Label #" + String(index)
        wedge.shape.borderSize = WedgeBorderSize.small
        wedge.label.font = wedge.label.font.withSize(20)
        
        return wedge
    }
    
    
    //Target was added in viewDidLoad for the valueChanged UIControlEvent
    @objc func spinWheelDidChangeValue(sender: AnyObject) {
        print("Selected value changed to " + String(self.spinWheelControl.selectedIndex))
    }
    
    
    func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl) {
        print("The spin wheel did end decelerating.")
    }
    
    
    func didTapOnWedgeAtIndex(spinWheel: SpinWheelControl, index:UInt) {
        print("The spin wheel was tapped at index: ", index)
    }
    
    
    func spinWheelDidRotateByRadians(radians: Radians) {
        print("The wheel did rotate this many radians: " + String(describing: radians))
    }
}
