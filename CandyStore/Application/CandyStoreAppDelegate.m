//
//  CandyStoreAppDelegate.m
//  CandyStore
//
//  Created by Daniel Norton on 7/22/11.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "CandyStoreAppDelegate.h"
#import "CandyStoreViewController.h"


@implementation CandyStoreAppDelegate

@synthesize window;
@synthesize viewController;


#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[window release];
	[viewController release];
    [super dealloc];
}


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {	 
	self.window.rootViewController = self.viewController;
	[self.window makeKeyAndVisible];
    return YES;
}


@end

