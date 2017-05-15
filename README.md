# Spin Wheel Control v0.1.0

## Synopsis

PLEASE NOTE: This UI control is still in development stage and may not work as expected. It is still very actively under construction. Use at your own risk.

Spin Wheel Control is a wheel of fortune-style spinning wheel control that allows selection of an item. It is written in the Swift programming language and to be used in iOS apps.

The code is a Swift derivation, port, and enhancement based loosely on the Objective-C "SMWheelControl" CocoaPod written by Cesare Rocchi and Simone Civetta found at https://cocoapods.org/pods/SMWheelControl.

Main languages and technologies used: Swift, UI Kit, Core Animation, Cocoa Pods, Xcode


## Installation 

This project is still under construction and may not work as expected until its first stable release.

To run this on your own machine, install Cocoapods, create a podfile, and run pod install from the command line while inside your project's root directory.

To make this work in your Objective-C project:
In your project's (not the target's) build settings, set the Defines Module flag to YES.
Find your product module name by going to your target's (not the project's) build setting and search for Project Module Name.
Add the SpinWheelControl files to your project.
Import <productModuleName-Swift.h> in every Objective-C class you plan to use your Swift classes in. This file is created automatically by the compiler when you include Swift classes in an Objective-C project.


## Initialization


## Data Source Methods

func numberOfWedgesInSpinWheel(spinWheel: SpinWheelControl) -> UInt
Specify the number of wedges in the spin wheel by returning a positive value that is greater than 1


## Delegate Methods

func spinWheelDidEndDecelerating(spinWheel: SpinWheelControl)
Triggered when the spin wheel has come to rest after spinning.

func spinWheelDidRotateByRadians(radians: CGFloat)
Triggered when the spin wheel has spun past a specified number of radians.

