//
//  NSString+NDWebKit.m
//  NDWebKit
//
//  Created by Nguyen Duc Hiep on 6/25/20.
//  Copyright © 2020 Nguyen Duc Hiep. All rights reserved.
//

#import <NDWebKit/NSString+NDWebKit.h>

#import <NDLog/NDLog.h>

@implementation NSString (NDWebKit)

- (NSString*)nd_jsEquivalent {
  NSError* err = nil;
  auto data = [NSJSONSerialization dataWithJSONObject:@[ self ]
                                              options:kNilOptions
                                                error:&err];
  if (err) {
    NDAssert(false,
             @"Can not calculate js equivalent of string: '%@', error: '%@'.",
             self, err);
    return nil;
  }

  auto encodedString = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
  if (!encodedString) {
    NDAssert(false, @"Can not calculate js equivalent of string: '%@'.", self);
    return nil;
  }
  return [NSString stringWithFormat:@"%@[0]", encodedString];
}

@end
