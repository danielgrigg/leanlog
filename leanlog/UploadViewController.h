//
//  UploadViewController.h
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTPService.h"

@interface UploadViewController : UIViewController <FTPServiceDelegate, UITextFieldDelegate> {
  UILabel* _sendingLabel;
  UITextField* _usernameText;
  UITextField* _passwordText;
  UITextField* _remoteAddressText;  
  UIProgressView* _transferProgress;
  FTPService* _service;
  
  unsigned long long _transferFileSize; 
  NSMutableArray* _queuedTransfers;
}

- (IBAction)startPressed;
@property (nonatomic, retain) FTPService* service;
@property (nonatomic, retain) IBOutlet UILabel* sendingLabel;
@property (nonatomic, retain) IBOutlet UITextField * usernameText;
@property (nonatomic, retain) IBOutlet UITextField * passwordText;
@property (nonatomic, retain) IBOutlet UITextField * remoteAddressText;
@property (nonatomic, retain) IBOutlet UIProgressView * transferProgress;

@end
