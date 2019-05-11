//
//  ViewController.m
//  SpinWheelExample
//
//  Created by Josh Henry on 4/7/19.
//  Copyright © 2019 Big Smash Software. All rights reserved.
//

#import "ViewController.h"
@import SpinWheelControl;

@interface ViewController () <SpinWheelControlDelegate, SpinWheelControlDataSource> {
    SpinWheelControl *spinWheelControl;
}

@end

@implementation ViewController


static NSArray *colorPalette;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    colorPalette = [[NSArray alloc] initWithObjects:[UIColor blueColor],[UIColor brownColor],[UIColor cyanColor], [UIColor darkGrayColor], [UIColor greenColor], [UIColor magentaColor], [UIColor redColor], [UIColor orangeColor], [UIColor blackColor], [UIColor grayColor], [UIColor lightGrayColor], [UIColor purpleColor], [UIColor yellowColor], [UIColor whiteColor],nil];
    
    CGRect frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.width);
    spinWheelControl = [[SpinWheelControl alloc] initWithFrame:frame];

    [self.view addSubview:spinWheelControl];
    
    [spinWheelControl addTarget:self action:@selector(spinWheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    spinWheelControl.dataSource = self;
    spinWheelControl.delegate = self;
    
    spinWheelControl.wedgeBorderColor = [UIColor blackColor];
//    spinWheelControl.wedgeLabelOrientation = WedgeLabelOrientationAround;
    
    [spinWheelControl reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)numberOfWedgesInSpinWheelWithSpinWheel:(SpinWheelControl * _Nonnull)spinWheel {
    return 5;
}


- (SpinWheelWedge * _Nonnull)wedgeForSliceAtIndexWithIndex:(NSUInteger)index {
    SpinWheelWedge *wedge = [[SpinWheelWedge alloc] init];
    wedge.shape.fillColor = [[colorPalette objectAtIndex:index] CGColor];
    wedge.shape.borderSize = WedgeBorderSizeSmall;
    
    wedge.label.text = [NSString stringWithFormat:@"Label #%lu", (unsigned long)index];
    wedge.label.font = [UIFont systemFontOfSize:16.0f];
    
    return wedge;
}


- (void)spinWheelDidChangeValue:(id) obj {
    NSLog(@"Value Changed");
    NSLog(@"%ld", (long)spinWheelControl.selectedIndex);
}


- (void)spinWheelDidEndDeceleratingWithSpinWheel:(SpinWheelControl *)spinWheel {
    NSLog(@"The spin wheel did end decelerating.");
}


- (void) didTapOnWedgeAtIndexWithSpinWheel:(SpinWheelControl *)spinWheel index:(NSUInteger)index {
    NSLog(@"The spin wheel was tapped at index:");
    NSLog(@"%lu", (unsigned long)index);
}


- (void) spinWheelDidRotateByRadiansWithRadians:(CGFloat)radians {
//    NSLog(@"The wheel did rotate this many radians: ");
//    NSLog(radians);
}

@end
