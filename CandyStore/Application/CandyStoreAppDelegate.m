//
//  CandyStoreAppDelegate.m
//  CandyStore
//
//  Created by Daniel Norton on 7/22/11.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "CandyStoreAppDelegate.h"
#import "CandyShopService.h"
#import "ExchangeSubscriptionNotificationService.h"
#import "NSObject+popup.h"
#import "UIApplication+delegate.h"
#import "NSObject+popup.h"
#import "HTTPRequestService.h"


#define kReachabiltyMaxNotify 3
#define kExchangeTabIndex 2


@interface CandyStoreAppDelegate()

- (void)alertUserHasNotPurchasedExchange;
- (void)reachabilityChanged:(NSNotification *)note;
- (BOOL)shouldAlertForReachabilityChanged;

@end


@implementation CandyStoreAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize internetReach;


#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[window release];
	[tabBarController release];
	[internetReach release];
    [super dealloc];
}


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifer];
	
	[self reachabilityChanged:nil];
	
	[window setRootViewController:tabBarController];
	[window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	[service reset];
	[service release];
	
	[HTTPRequestService setReachabilityTest:^BOOL(void) {
		
		return [self canReachInternet];
	}];
}


#pragma mark UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
	
	int index = [aTabBarController.viewControllers indexOfObject:viewController];
	if (index != kExchangeTabIndex) return YES;
	
	if ([CandyShopService hasExchange]) {
		return YES;
	}
	
	[self alertUserHasNotPurchasedExchange];
	return NO;
}


#pragma mark -
#pragma mark CandyStoreAppDelegate
#pragma mark Public Messages
- (void)alertUserHasNotPurchasedExchange {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	
	if (!service.shouldNotify) {
		
		[service release];
		return;
	}
	
	service.counter++;
	[tabBarController popup:service.message];
	[service release];
}

- (BOOL)canReachInternet {
	return (internetReach.currentReachabilityStatus != NotReachable);
}


#pragma mark Private Extension
- (void)reachabilityChanged:(NSNotification *)note {
	
	if ([self canReachInternet]) return;
	if (![self shouldAlertForReachabilityChanged]) return;
	
	[self popup:@"Internet connectivity is not available. Some features will be disabled."];
}

- (BOOL)shouldAlertForReachabilityChanged {
	
	static BOOL hasNotifiedThisRun = NO;
	
	if (hasNotifiedThisRun) return NO;
	
	hasNotifiedThisRun = YES;
	
	NSString *const notifyKey = @"ReachabilityNotifyKey";
	int count = [[[NSUserDefaults standardUserDefaults] objectForKey:notifyKey] integerValue];
	if (count >= kReachabiltyMaxNotify) return NO;
	
	count++;
	NSString *countObject = [NSString stringWithFormat:@"%i", count];
	[[NSUserDefaults standardUserDefaults] setObject:countObject forKey:notifyKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return YES;
}


@end

