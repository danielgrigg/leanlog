//
//  GZWriter.m
//  leanlog
//
//  Created by Daniel Grigg on 4/04/12.
//  Copyright (c) 2012 Daniel Grigg. All rights reserved.
//

#import "GZWriter.h"

@interface GZWriter ()
//@property (nonatomic, assign) gzFile gf;
@end


@implementation GZWriter
//@synthesize gf = _gf;

-(BOOL)open:(NSString*)path {
  char buffer[256];
  if (![path getCString:buffer maxLength:256 encoding:NSUTF8StringEncoding]) return NO;
  
  _gf = gzopen(buffer, "wb");
  if (!_gf) return NO;
  
  _opQ = [[NSOperationQueue alloc] init];
  
  return YES;
}

-(void)doWrite {
  
}

-(void)write:(NSString*)text {
  [_opQ waitUntilAllOperationsAreFinished];
  [_opQ addOperationWithBlock:^(void) {
    
    gzFile gfCopy = _gf;
    NSUInteger maxNumBytes = [text maximumLengthOfBytesUsingEncoding:NSUTF8StringEncoding];    
    void* bigBuffer = malloc(maxNumBytes);
    NSRange range = NSMakeRange(0, [text length]);
    NSRange remaining;
    NSUInteger usedLength;
    [text getBytes:bigBuffer maxLength:maxNumBytes usedLength:&usedLength encoding:NSUTF8StringEncoding options:0 range:range remainingRange:&remaining];
    gzwrite(gfCopy, bigBuffer, usedLength);
    free(bigBuffer);
  }];
  
}

-(void)close {
  [_opQ waitUntilAllOperationsAreFinished];
  
  if (_gf) {
    gzclose(_gf);
    _gf = nil;
  }
}

-(void)dealloc {
  [super dealloc];
  
  if (_gf) {
    gzclose(_gf);
  }
}

@end
