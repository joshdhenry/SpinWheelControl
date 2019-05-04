//
//  AppDelegate.h
//  SpinWheelExample
//
//  Created by Josh Henry on 4/7/19.
//  Copyright © 2019 Big Smash Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

