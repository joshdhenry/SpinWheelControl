Pod::Spec.new do |s|
s.name             = 'SpinWheelControl'
s.version          = '0.2.0'
s.summary          = 'An inertial spinning wheel UI control that allows selection of an item.'

s.description      = <<-DESC
                    Spin Wheel Control is a wheel of fortune-style inertial spinning wheel UI control that allows selection of an item. It is written in the Swift programming language and to be used in iOS apps. The code is a Swift derivation, port, and enhancement based loosely on the Objective-C SMWheelControl CocoaPod written by Cesare Rocchi and Simone Civetta found at https://cocoapods.org/pods/SMWheelControl.
                    DESC

s.homepage         = 'https://github.com/joshdhenry/SpinWheelControl'
s.license          = { :type => 'BSD', :file => 'LICENSE.md' }
s.author           = { 'Josh Henry' => 'Josh@BigSmashSoftware.com' }
s.source           = { :git => 'https://github.com/joshdhenry/SpinWheelControl.git', :tag => s.version.to_s }

s.framework        = 'UIKit'

s.ios.deployment_target = '10.0'
s.source_files = 'SpinWheelControl/*.{swift,h,m}'

end
