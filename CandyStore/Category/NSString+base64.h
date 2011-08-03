//
//  NSString+base64.h
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//
// Thanks
// http://stackoverflow.com/questions/392464/any-base64-library-on-iphone-sdk
//

@interface NSString(base64)

+ (NSString *)base64StringFromData:(NSData *)data length:(int)length;

@end
