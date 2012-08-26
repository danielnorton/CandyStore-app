//
//  UIApplication+delegate.m
// 
//
//  Created by Daniel Norton on 11/3/10.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "UIApplication+delegate.h"


@implementation UIApplication(delegate)

+ (CandyStoreAppDelegate *)thisApp {
	return (CandyStoreAppDelegate *)[[UIApplication sharedApplication] delegate];
}

+ (NSString *)appName {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

+ (NSString *)version {
	return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

@end
