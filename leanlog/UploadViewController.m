//
//  UploadViewController.m
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import "UploadViewController.h"
#import "util.h"
#import "leanlog.h"

@interface UploadViewController ()
- (BOOL) sendQueuedTransfer;
@end


@implementation UploadViewController

@synthesize sendingLabel = _sendingLabel;
@synthesize usernameText = _usernameText;
@synthesize passwordText = _passwordText;
@synthesize remoteAddressText = _remoteAddressText;
@synthesize service = _service;
@synthesize transferProgress = _transferProgress;

-(void) writeToTextFile:(NSString*) name {
  //get the documents directory:
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  
  //make a file name to write the data to using the documents directory:
  NSString *fileName = [NSString stringWithFormat:@"%@/%@", documentsDirectory, name];
  //create content - four lines of text
  NSString *content = [NSString stringWithFormat:@"%@\nOne\nTwo\nThree\nFour\nFive\nSix", 
                       [NSDate date]];
  for(int i = 0; i < 500; ++i) {
    content = [content stringByAppendingString:@"\nthe quick brown fox jumped over the lazy dog"];
    content = [content stringByAppendingString:@"\none two three four five six seven eight nine ten"];
  }
  
  //save content to the documents directory
  [content writeToFile:fileName 
            atomically:NO 
              encoding:NSStringEncodingConversionAllowLossy 
   //   NSUTF8StringEncoding
                 error:nil];
  
}

- (void)statusChanged:(FTPService*)service status:(NSString*)aStatus {
  if (![aStatus isEqualToString:self.sendingLabel.text]) {
    self.sendingLabel.text = aStatus;
  }
}

- (void)bytesSentChanged:(FTPService*)service progress:(size_t)aProgress {  
  self.transferProgress.progress = (float)aProgress / (float)_transferFileSize;
}

- (void)transferComplete:(FTPService*)service {
  [self sendQueuedTransfer];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  NSLog(@"Documents: %@", documentsDirectory());
  
  self.sendingLabel.text = @"Ready";
  self.transferProgress.progress = 0.0;
  _transferFileSize = 1.0;
  self.remoteAddressText.text = @"ftp://192.168.1.20/";
  self.usernameText.text = @"ftpuser";
  self.passwordText.text = @"g3ck0g1mp";
  _service = [[FTPService alloc] init];
  self.service.delegate = self;
}

- (BOOL) sendQueuedTransfer {
  if ([_queuedTransfers count] == 0) {
    [_queuedTransfers release];
    return NO;
  }
  
  NSString* nextPath = documentPath([_queuedTransfers lastObject]);
  [_queuedTransfers removeLastObject];
  
  _transferProgress.progress = 0.0;
  NSDictionary* attribs = [[NSFileManager defaultManager] attributesOfItemAtPath:nextPath error:NULL];
  _transferFileSize = [[attribs objectForKey:NSFileSize] unsignedLongLongValue];
  
  NSURL* url = [NSURL URLWithString: self.remoteAddressText.text];
  NSString* user = self.usernameText.text;
  NSString* pw = self.passwordText.text;
  
  self.sendingLabel.text = [nextPath lastPathComponent];
  [self.service putFile:nextPath to:url user:user password:pw];
  return YES;
}

- (IBAction) startPressed {
  
  _queuedTransfers = [[NSMutableArray alloc] initWithArray:docsWithExtension(LOG_FILE_EXTENSION)];
  [self sendQueuedTransfer];
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
  
    [_service release];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  assert(textField == self.usernameText || textField == self.passwordText || textField == self.remoteAddressText);
  [textField resignFirstResponder];
  return NO;
}


@end
