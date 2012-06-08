//
//  leanlogAppDelegate.m
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import "leanlogAppDelegate.h"
#import "util.h"
#include <zlib.h>
#import "leanlog.h"

NSString* const LOG_FILE_EXTENSION = @"gz";

double radiansToDegrees(double r) { return 180.0 * r / 3.14159265358979; }

@interface leanlogAppDelegate ()
@property (nonatomic, retain) CLLocationManager* locationManager;
@property (nonatomic, retain) CMMotionManager* motionManager;
@end

@implementation leanlogAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize locationManager = _locationManager;
@synthesize motionManager = _motionManager;
@synthesize locationCoordinate = _locationCoordinate;
@synthesize locationAltitude = _locationAltitude;
@synthesize locationTimestamp = _locationTimestamp;
@synthesize attitudePitch = _attitudePitch;
@synthesize attitudeYaw = _attitudeYaw;
@synthesize attitudeRoll = _attitudeRoll;

#pragma mark * CLLocationManager delegate

- (void) locationManager:(CLLocationManager *)manager 
     didUpdateToLocation:(CLLocation *)newLocation 
            fromLocation:(CLLocation *)oldLocation {
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ssS"];
  
  NSString* line = [NSString stringWithFormat:@"%@: %lf %f %.1f %.1f %.1f\n",
                    [dateFormatter stringFromDate: newLocation.timestamp],
                    newLocation.coordinate.latitude,
                    newLocation.coordinate.longitude,
                    newLocation.altitude,
                    newLocation.horizontalAccuracy,
                    newLocation.verticalAccuracy];
  [dateFormatter release];
#ifdef DEBUG
  NSLog(@"%@", line);
#endif
  self.locationCoordinate = newLocation.coordinate;
  self.locationAltitude = newLocation.altitude;
  self.locationTimestamp = newLocation.timestamp;
  
  if (_isLogging) {
    [_gpsLog write:line];
  }
}

- (void)locationManager:(CLLocationManager *)manager 
       didUpdateHeading:(CLHeading *)newHeading {
#ifdef DEBUG
//  NSLog(@"Heading: %@", newHeading);
#endif
}

- (void)locationManager:(CLLocationManager *)manager 
       didFailWithError:(NSError *)error {
#ifdef DEBUG
  NSLog(@"Could not find location: %@", error);
#endif
}

-(void) startLogging:(double)imuRate {
  [self.locationManager startUpdatingLocation];
  [self.locationManager startUpdatingHeading];
  double actualIMURate = MIN(MAX_IMU_RATE, MAX(MIN_IMU_RATE, imuRate));
  self.motionManager.deviceMotionUpdateInterval = (1.0 / actualIMURate);


  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm"];
  
  NSString* gpsLogPath = 
    documentPath([NSString stringWithFormat:@"%@_gps.txt.gz", 
                  [dateFormatter stringFromDate:[NSDate date]]]);
  
  NSString* imuLogPath = 
  documentPath([NSString stringWithFormat:@"%@_%.1f-Hz_imu.txt.gz", 
                [dateFormatter stringFromDate:[NSDate date]], actualIMURate]);

  [dateFormatter release];
  
  if (![_gpsLog open:gpsLogPath]) {
    NSLog(@"Error opening gps log file: %@", gpsLogPath);
  }
  if (![_imuLog open:imuLogPath]) {
    NSLog(@"Error opening imu log file: %@", imuLogPath);
  }
 
  // Core motion timestamps are relative to system-boot.  So find the offset
  // between 1970 and system-boot to adjust CM timestamps to a 1970 date.
  NSTimeInterval uptime = [[NSProcessInfo processInfo] systemUptime];
  NSTimeInterval since1970 = [[NSDate date] timeIntervalSince1970];
  _bootTimeWrt1970 = since1970 - uptime;
  
  [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical 
                                                          toQueue:_motionOpQ 
                                                      withHandler:   ^(CMDeviceMotion *motionData, NSError *error) {
     CMAttitude* attitude = [motionData attitude];

     self.attitudePitch = radiansToDegrees([attitude pitch]);
     self.attitudeRoll = radiansToDegrees([attitude roll]);
     self.attitudeYaw = radiansToDegrees([attitude yaw]);

     NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
     [dateFormatter setDateFormat:@"yyyy-MM-dd_HH:mm:ssSSS"];
     
     NSTimeInterval ts1970 = [motionData timestamp] + _bootTimeWrt1970;
     NSDate* ts = [NSDate dateWithTimeIntervalSince1970: ts1970];
     NSString* line = [NSString stringWithFormat:@"%@ %f %f %f\n",
                       [dateFormatter stringFromDate: ts],
                       self.attitudePitch,
                       self.attitudeRoll,
                       self.attitudeYaw];
     
     if (_isLogging) {
       [_imuLog write:line];                  
     }
#ifdef DEBUG
     NSLog(@"--%@-- %f %f %f", [dateFormatter stringFromDate:ts], self.attitudePitch,
           self.attitudeRoll, self.attitudeYaw);
#endif
     
     [dateFormatter release];
   }];

  
  _isLogging = YES;
  ([UIApplication sharedApplication]).idleTimerDisabled = YES;
  ([UIScreen mainScreen]).brightness = 0.0;
}

-(void) stopLogging {
  [self.motionManager stopDeviceMotionUpdates];
  [self.locationManager stopUpdatingLocation];
  [self.locationManager stopUpdatingHeading];
  
  _isLogging = NO;
    ([UIApplication sharedApplication]).idleTimerDisabled = NO;
  ([UIScreen mainScreen]).brightness = _defaultBrightness;
  [_gpsLog close];
  [_imuLog close];
}


- (BOOL)application:(UIApplication *)application 
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  // Override point for customization after application launch.
  // Add the tab bar controller's current view as a subview of the window
  self.window.rootViewController = self.tabBarController;
  [self.window makeKeyAndVisible];
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.distanceFilter = kCLDistanceFilterNone;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
  self.motionManager = [[CMMotionManager alloc] init];
  self.motionManager.deviceMotionUpdateInterval = DEFAULT_IMU_RATE;
  
  _motionOpQ = [[NSOperationQueue currentQueue] retain];
  _gpsLog = [[GZWriter alloc] init];
  _imuLog = [[GZWriter alloc] init];
  _isLogging = NO;
  _defaultBrightness = [[UIScreen mainScreen] brightness];

  return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
}

- (void)dealloc
{
  [_window release];
  [_tabBarController release];
  [_locationManager release];
  [_motionOpQ release];
  [_gpsLog release];
  [_imuLog release];
  [super dealloc];
}

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
 {
 }
 */

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
 {
 }
 */

@end
