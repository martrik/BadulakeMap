//
//  ViewController.m
//  Badulake Creator
//
//  Created by Martí Serra Vivancos on 27/05/15.
//  Copyright (c) 2015 Martí Serra Vivancos. All rights reserved.
//

#import "ViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UISwitch *alwaysopened;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) MKMapView *map;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager DELETE:@"http://badulakemap.herokuapp.com"
      parameters:@{@"id": @75}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                       }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"insertProfileParams error: %@", error);
              
          }];

    
    // Init location mamanger
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager startUpdatingLocation];
    
    _nameText.delegate = self;
    
   // _map = [[MKMapView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 220, self.view.frame.size.width, 220)];
   // [self.view addSubview:_map];
    
}

- (void)getLocationPermission {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // Special call required in iOS 8
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) [_locationManager requestWhenInUseAuthorization];
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"App Permission Denied", nil)
                                                        message:NSLocalizedString(@"To re-enable, please go to Settings and turn on Location Service for this app.", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self getLocationPermission];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    _latitudeLabel.text = [NSString stringWithFormat:@"Latitude: %f", location.coordinate.latitude];
    _longitudeLabel.text = [NSString stringWithFormat:@"Longitude: %f", location.coordinate.longitude];
    
    [_map removeAnnotations:[_map annotations]];
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:location.coordinate];
    [annotation setTitle:@"Your location"];
    [_map addAnnotation:annotation];
    
    MKCoordinateRegion mapRegion;
    mapRegion.center = manager.location.coordinate;
    mapRegion.span.latitudeDelta = 0.15;
    mapRegion.span.longitudeDelta = 0.15;
    [_map setRegion:mapRegion animated: YES];

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)saveBadulake:(id)sender {
    _saveButton.enabled = NO;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager POST:@"https://badulakemap.herokuapp.com/badulake/"
       parameters:@{@"name":_nameText.text,@"longitude":[NSNumber numberWithFloat:_locationManager.location.coordinate.longitude],@"latitude":[NSNumber numberWithFloat:_locationManager.location.coordinate.latitude],@"alwaysopened":@(_alwaysopened.on)}
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              _saveButton.enabled = YES;
              if ([operation.response statusCode] == 201) {
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Badulake added"
                                                                  message:@"This Badulake has been addded correctly to the db."
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                        otherButtonTitles:nil];
                  [alert show];
                  
                  _nameText.text = @"";
              }
              
              if ([operation.response statusCode] == 206) {
                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing info"
                                                                  message:@"TPleas check if you are submiting all the needed info."
                                                                 delegate:nil
                                                        cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                        otherButtonTitles:nil];
                  [alert show];
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"insertProfileParams error: %@", error);
              
          }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
