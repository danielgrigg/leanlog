//
//  ManageViewController.h
//  leanlog
//
//  Created by Daniel Grigg on 2/04/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManageViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  UITableView *               _logsTableView;
  NSMutableArray* _logEntries;
  BOOL _isEditing; 
  UIBarButtonItem* _editBarButton;
}

- (IBAction)toggleEditLogs:(id)sender;
- (void)setEditing:(BOOL)editing;
- (IBAction)refresh:(id)sender;

@property (nonatomic, retain) IBOutlet UITableView* logsTableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* editBarButton;

@end
