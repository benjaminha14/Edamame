//
//  ViewController.h
//  ActualWaterSensor
//
//  Created by Ben Ha on 1/16/16.
//  Copyright © 2016 Ben Ha. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioSessionManager.h"
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *output;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *low;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *average;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *high;

@end
