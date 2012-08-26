//
//  UIApplication+delegate.h
// 
//
//  Created by Daniel Norton on 11/3/10.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyStoreAppDelegate.h"

@interface UIApplication(delegate)
+ (CandyStoreAppDelegate *)thisApp;
+ (NSString *)appName;
+ (NSString *)version;
@end
