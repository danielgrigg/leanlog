//
//  GZWriter.h
//  leanlog
//
//  Created by Daniel Grigg on 4/04/12.
//  Copyright (c) 2012 Daniel Grigg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <zlib.h>

@interface GZWriter : NSObject {
  NSOperationQueue* _opQ;
  gzFile _gf;

}

-(BOOL)open:(NSString*)path;
-(void)write:(NSString*)text;
-(void)close;
-(void)dealloc;

@end
