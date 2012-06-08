//
//  MeasureController.m
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import "MeasureViewController.h"
#import "leanlogAppDelegate.h"
#import "leanlog.h"

@implementation MeasureViewController

@synthesize toggleMeasureButton = _toggleMeasureButton;
@synthesize metricsTableView = _metricsTableView;
@synthesize imuRateText = _imuRateText;

#pragma mark Table methods

static const NSInteger ORIENTATION = 0;
static const NSInteger LOCATION = 1;


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2; // Orientation + Location
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  assert(section < 2);
  assert(tableView == self.metricsTableView);
  
  if (ORIENTATION == section) {
    return 3;
  } else if (LOCATION == section) {
    return 3;
  }
  return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  static NSString* titles[] = {@"Orientation", @"Location"};
  return titles[section];
}

// - (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {  }

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString* locationKeys[] = {@"Latitude", @"Longitude", @"Altitude"};
  static NSString* orientationkeys[] = {@"Pitch", @"Yaw", @"Roll"};
  double pitchYawRoll[] = {AppDelegate.attitudePitch, AppDelegate.attitudeYaw, AppDelegate.attitudeRoll};
  double latLngAlt[] = {
    AppDelegate.locationCoordinate.latitude,
    AppDelegate.locationCoordinate.longitude,
    AppDelegate.locationAltitude};
  
  UITableViewCell* cell;
  assert(indexPath.section < 2);
  assert(indexPath.row < 3);

  cell = [self.metricsTableView dequeueReusableCellWithIdentifier:@"measurement"];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"measurement"] autorelease];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //    cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
  }
  assert(cell != nil);

  
  if (indexPath.section == LOCATION) {
    cell.textLabel.text = locationKeys[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.4f", latLngAlt[indexPath.row]];
    
    
  }
  else if (ORIENTATION == indexPath.section) {    
    cell.textLabel.text = orientationkeys[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f", pitchYawRoll[indexPath.row]];
  }
  
  return cell;
}


- (void)timerHandler:(NSTimer*)theTimer {
  //CMAttitude* attitude = [[_motionManager deviceMotion] attitude];
  //NSLog(@"pitch: %f, yaw: %f, roll: %f", [attitude pitch], [attitude yaw], [attitude roll]);
  
  [self.metricsTableView reloadData];
}

- (void)startMeasurement {
  if (!_isMeasuring) {
       
    [AppDelegate startLogging:[self.imuRateText.text doubleValue]];
    self.imuRateText.enabled = NO;
    [self.toggleMeasureButton setTitle:@"Stop"];
  } else {
    [AppDelegate stopLogging];
    self.imuRateText.enabled = YES;
    [self.toggleMeasureButton setTitle:@"Start"];
  }
  _isMeasuring = !_isMeasuring;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  _isMeasuring = false;

  _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 
                                              target:self 
                                            selector:@selector(timerHandler:) 
                                            userInfo:nil 
                                             repeats:YES];  
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  // Return YES for supported orientations
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  assert(textField == self.imuRateText);
  if ([self.imuRateText.text doubleValue] < MIN_IMU_RATE) {
    self.imuRateText.text = [NSString stringWithFormat:@"%f", MIN_IMU_RATE];
  }
  if ([self.imuRateText.text doubleValue] > MAX_IMU_RATE) {
    self.imuRateText.text = [NSString stringWithFormat:@"%f", MAX_IMU_RATE];
  }
  [textField resignFirstResponder];
  return NO;
}

@end
