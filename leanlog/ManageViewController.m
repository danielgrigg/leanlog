//
//  ManageViewController.m
//  leanlog
//
//  Created by Daniel Grigg on 2/04/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import "ManageViewController.h"
#import "util.h"
#import "leanlog.h"

//#define STUBBED

@interface ManageViewController ()
@property (nonatomic, retain)   NSMutableArray *  logEntries;
@end

@implementation ManageViewController

@synthesize logEntries     = _logEntries;
@synthesize logsTableView = _logsTableView;
@synthesize editBarButton = _editBarButton;

- (NSString*) logNameByIndex:(NSUInteger)idx {
  return [docsWithExtension(LOG_FILE_EXTENSION) objectAtIndex:idx];
}

- (void)toggleEditLogs:(id)sender {
  _isEditing = !_isEditing;
  [self setEditing:_isEditing];
}

- (void)setEditing:(BOOL)editing {
  if(editing) {
    self.editBarButton.title = @"Cancel";
  } else {
    self.editBarButton.title = @"Edit";
  }
  [self.logsTableView setEditing:editing animated:YES];
}

- (IBAction)refresh:(id)sender {
  [self.logsTableView reloadData];
}

#pragma mark *UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
  assert(tv == self.logsTableView);
  assert(0 == section);
  return [docsWithExtension(LOG_FILE_EXTENSION) count];
}


- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell* cell;
  
  cell = [self.logsTableView dequeueReusableCellWithIdentifier:@"myCell"];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"] autorelease];
  }
  assert(cell != nil);
  
  cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
  cell.textLabel.textAlignment = UITextAlignmentCenter;
  cell.selectionStyle = UITableViewCellSelectionStyleGray; // UITableViewCellSelectionStyleNone;
  cell.textLabel.text = [docsWithExtension(LOG_FILE_EXTENSION) objectAtIndex:indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  assert(tv == self.logsTableView);
  
  // If row is deleted, remove it from the list.
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    NSString* removePath = documentPath([self logNameByIndex:indexPath.row]);
    [[NSFileManager defaultManager] removeItemAtPath:removePath error:nil];
    [self.logsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
  }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {
  [self refresh:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  [self setEditing:NO];   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
  [_logEntries release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
