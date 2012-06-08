//
//  FTPStreamDelegate.h
//  leanlog
//
//  Created by Daniel Grigg on 29/03/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  kSendBufferSize = 32768
};


@protocol FTPServiceDelegate;

@interface FTPService : NSObject <NSStreamDelegate>
{
  NSOutputStream *            _networkStream;
  NSInputStream *             _fileStream;
  uint8_t                     _buffer[kSendBufferSize];
  size_t                      _bufferOffset;
  size_t                      _bufferLimit;
  size_t                      _bytesSent;
  NSString*                   _status;
  id<FTPServiceDelegate>      _delegate;
}

@property (assign) id<FTPServiceDelegate> delegate;
@property (nonatomic, retain) NSString* status;
@property (nonatomic, assign) size_t bytesSent;

- (void) putFile:(NSString*) filePath
              to:(NSURL*) serverURL
            user:(NSString*)aUser
        password:(NSString*)aPassword;

@end

@protocol FTPServiceDelegate <NSObject>
@optional
- (void)statusChanged:(FTPService*)service status:(NSString*)aStatus;
- (void)bytesSentChanged:(FTPService*)service progress:(size_t)aProgress;
- (void)transferComplete:(FTPService*)service;
@end
