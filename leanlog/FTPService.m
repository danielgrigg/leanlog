//
//  FTPStreamDelegate.m
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import "FTPService.h"
#include <CFNetwork/CFNetwork.h>

@interface FTPService ()

@property (nonatomic, retain)   NSOutputStream *  networkStream;
@property (nonatomic, retain)   NSInputStream *   fileStream;
@property (nonatomic, readonly) uint8_t *         buffer;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;

@end

@implementation FTPService

@synthesize status = _status;
@synthesize bytesSent = _bytesSent;
@synthesize networkStream = _networkStream;
@synthesize fileStream    = _fileStream;
@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;
@synthesize delegate = _delegate;

- (uint8_t *)buffer
{
  return self->_buffer;
}

- (void)setStatus:(NSString *)aStatus
{
  if ([(id)_delegate respondsToSelector:@selector(statusChanged:status:)]) {
    [_delegate statusChanged:self status:aStatus];
  }
  _status = aStatus;
}

- (void)setBytesSent:(size_t)sent {
  if ([(id)_delegate respondsToSelector:@selector(bytesSentChanged:progress:)]) {
    [_delegate bytesSentChanged:self progress:sent];
  }
  _bytesSent = sent;
}

- (void) putFile:(NSString*) filePath
              to:(NSURL*) serverURL
            user:(NSString*)aUser
        password:(NSString *)aPassword {
  BOOL                    success;
  NSURL *                 url;
  CFWriteStreamRef        ftpStream;
  
  assert(filePath != nil);
  assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
  
  assert(self.networkStream == nil);      // don't tap send twice in a row!
  assert(self.fileStream == nil);         // ditto
  
  // First get and check the URL.
  //url = [NSURL URLWithString:serverURL];
  
  url = 
    [NSMakeCollectable(
                       CFURLCreateCopyAppendingPathComponent(NULL, 
                                                             (CFURLRef) serverURL, 
                                                             (CFStringRef) [filePath lastPathComponent], 
                                                             false)) 
         autorelease];

  success = (url != nil);
  
  // If the URL is bogus, let the user know.  Otherwise kick off the connection.
  if ( ! success) {
    NSLog(@"Invalid URL");    
  
  } else {
    
    self.fileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    assert(self.fileStream != nil);
    
    [self.fileStream open];
        
    ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (CFURLRef) url);
    assert(ftpStream != NULL);
    
    self.networkStream = (NSOutputStream *) ftpStream;
    
    success = [self.networkStream setProperty:aUser forKey:(id)kCFStreamPropertyFTPUserName];
    assert(success);
    success = [self.networkStream setProperty:aPassword forKey:(id)kCFStreamPropertyFTPPassword];
    assert(success);
    
    self.networkStream.delegate = self;
    [self.networkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.status = @"Initialized";
    self.bytesSent = 0;
    [self.networkStream open];
    
    // Have to release ftpStream to balance out the create.  self.networkStream 
    // has retained this for our persistent use.
    
    CFRelease(ftpStream);

  }

}

- (void)_stopSendWithStatus:(NSString *)statusString
{
  if (self.networkStream != nil) {
    [self.networkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.networkStream.delegate = nil;
    [self.networkStream close];
    self.networkStream = nil;
  }
  if (self.fileStream != nil) {
    [self.fileStream close];
    self.fileStream = nil;
  }
  self.status = statusString;
  [_delegate transferComplete:self];
}



- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
  assert(aStream == self.networkStream);
  
  switch (eventCode) {
    case NSStreamEventOpenCompleted: {
      self.status = @"Opened connection";
    } break;
    case NSStreamEventHasBytesAvailable: {
      assert(NO);     // should never happen for the output stream
    } break;
    case NSStreamEventHasSpaceAvailable: {
      self.status = @"Sending";
      // If we don't have any data buffered, go read the next chunk of data.
      
      if (self.bufferOffset == self.bufferLimit) {
        NSInteger   bytesRead;
        
        bytesRead = [self.fileStream read:self.buffer maxLength:kSendBufferSize];
        
        if (bytesRead == -1) {
          [self _stopSendWithStatus:@"File read error"];

        } else if (bytesRead == 0) {
          [self _stopSendWithStatus:@"Complete"];
        } else {
          self.bufferOffset = 0;
          self.bufferLimit  = bytesRead;
        }
      }
      
      // If we're not out of data completely, send the next chunk.
      if (self.bufferOffset != self.bufferLimit) {
        NSInteger   bytesWritten;
        bytesWritten = [self.networkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
          [self _stopSendWithStatus:@"Network write error"];
        } else {
          self.bufferOffset += bytesWritten;
          self.bytesSent += bytesWritten;
        }
      }
    } break;
    case NSStreamEventErrorOccurred: {
      [self _stopSendWithStatus:@"Couldn't connect to server"];
    } break;
    case NSStreamEventEndEncountered: {
    } break;
    default: {
      assert(NO);
    } break;
  }
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)dealloc
{
  [self _stopSendWithStatus:@"Stopped"];
    
  [super dealloc];
}


@end
