//
//  CandyStoreAppDelegate.m
//  CandyStore
//
//  Created by Daniel Norton on 7/22/11.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "CandyStoreAppDelegate.h"


@implementation CandyStoreAppDelegate

@synthesize window;
@synthesize aboutViewController;


#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[window release];
	[aboutViewController release];
    [super dealloc];
}


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[window setRootViewController:aboutViewController];
	[window makeKeyAndVisible];
    return YES;
}


@end

