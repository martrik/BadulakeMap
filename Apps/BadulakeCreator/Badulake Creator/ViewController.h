//
//  ViewController.h
//  Badulake Creator
//
//  Created by Martí Serra Vivancos on 27/05/15.
//  Copyright (c) 2015 Martí Serra Vivancos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface ViewController : UIViewController <CLLocationManagerDelegate, UITextFieldDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;



@end

