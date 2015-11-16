//
//  AppDelegate.h
//  SharkFeed_XiaofenLiu
//
//  Created by Xiaofen Liu on 11/12/15.
//  Copyright © 2015 Xiaofen Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "PhotoViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) ViewController *splashViewController;

@property (nonatomic, retain) PhotoViewController * photoViewController;

@end

