//
//  ViewController.m
//  SpinWheelExample
//
//  Created by Josh Henry on 4/7/19.
//  Copyright © 2019 Big Smash Software. All rights reserved.
//

#import "ViewController.h"
//#import <SpinWheelExample-Swift.h>
@import SpinWheelControl;

@interface ViewController () <SpinWheelControlDelegate, SpinWheelControlDataSource> {
    SpinWheelControl *s;
}

@end

@implementation ViewController


static NSArray *colorPalette;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    colorPalette = [[NSArray alloc] initWithObjects:[UIColor blueColor],[UIColor brownColor],[UIColor cyanColor], [UIColor darkGrayColor], [UIColor greenColor], [UIColor magentaColor], [UIColor redColor], [UIColor orangeColor], [UIColor blackColor], [UIColor grayColor], [UIColor lightGrayColor], [UIColor purpleColor], [UIColor yellowColor], [UIColor whiteColor],nil];
    
    CGRect frame = CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.width);
    s = [[SpinWheelControl alloc] initWithFrame:frame];
    [self.view addSubview:s];
    [s addTarget:self action:@selector(spinWheelDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    s.dataSource = self;
    s.delegate = self;
    [s reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSUInteger)numberOfWedgesInSpinWheelWithSpinWheel:(SpinWheelControl * _Nonnull)spinWheel {
    return 8;
}


- (SpinWheelWedge * _Nonnull)wedgeForSliceAtIndexWithIndex:(NSUInteger)index {
    SpinWheelWedge *wedge = [[SpinWheelWedge alloc] init];
    wedge.shape.fillColor =  [[colorPalette objectAtIndex:index] CGColor];
    wedge.label.text = [NSString stringWithFormat:@"Label #%lu", (unsigned long)index];
    
    return wedge;
}


- (void)spinWheelDidChangeValue:(id) obj {
    NSLog(@"Value Changed");
    NSLog(@"%ld", (long)s.selectedIndex);
}


@end
