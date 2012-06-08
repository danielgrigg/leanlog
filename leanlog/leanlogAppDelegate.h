//
//  leanlogAppDelegate.h
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "GZWriter.h"
#import "ManageViewController.h"

double radiansToDegrees(double r);

@interface leanlogAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate> {
  CLLocationManager* _locationManager;
  CMMotionManager* _motionManager;
  
  CLLocationCoordinate2D _locationCoordinate;
  CLLocationDistance _locationAltitude;
  NSDate* _locationTimestamp;
  NSOperationQueue* _motionOpQ; 

  GZWriter* _gpsLog;
  GZWriter* _imuLog;
  BOOL _isLogging;
  
  double _attitudePitch;
  double _attitudeYaw;
  double _attitudeRoll;
  
  float _defaultBrightness;
  
  NSTimeInterval _bootTimeWrt1970;
}

@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;
@property (nonatomic, assign) CLLocationDistance locationAltitude;
@property (nonatomic, assign) double attitudePitch;
@property (nonatomic, assign) double attitudeYaw;
@property (nonatomic, assign) double attitudeRoll;
@property (nonatomic, copy) NSDate* locationTimestamp;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

-(void) startLogging:(double)imuRate;
-(void) stopLogging;
@end

#define AppDelegate ((leanlogAppDelegate *)[[UIApplication sharedApplication] delegate])