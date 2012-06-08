//
//  util.c
//  leanlog
//
//  Created by Daniel Grigg on 2/04/12.
//  Copyright 2012 Daniel Grigg. All rights reserved.
//

#import "util.h"

NSString* documentsDirectory(void) {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths objectAtIndex:0];
}


NSArray* docsWithExtension(NSString* ext) {
  NSArray* docFiles = [[NSFileManager defaultManager] 
                       contentsOfDirectoryAtPath:documentsDirectory() error:nil];
  return [docFiles pathsMatchingExtensions:[NSArray arrayWithObject:ext]];
}

NSString* documentPath(NSString* docName) {
  return [documentsDirectory() stringByAppendingPathComponent:docName];
}
