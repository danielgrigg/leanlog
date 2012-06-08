//
//  MeasureController.h
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MeasureViewController : UIViewController  <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
  UIBarButtonItem* _toggleMeasureButton;
  bool _isMeasuring;
  UITableView* _metricsTableView;
  NSTimer* _timer;
  UITextField* _imuRateText;
}
- (void)timerHandler:(NSTimer*)theTimer;

- (IBAction)startMeasurement;
@property (nonatomic, retain) IBOutlet UITableView* metricsTableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * toggleMeasureButton;
@property (nonatomic, retain) IBOutlet UITextField* imuRateText;

@end
