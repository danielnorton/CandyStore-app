//
//  CandyStoreAppDelegate.m
//  CandyStore
//
//  Created by Daniel Norton on 7/22/11.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "CandyStoreAppDelegate.h"
#import "ExchangeSubscriptionNotificationService.h"
#import "NSObject+popup.h"
#import "UIApplication+delegate.h"
#import "NSObject+popup.h"
#import "HTTPRequestService.h"
#import "Model.h"
#import "TransactionReceiptService.h"


#define kReachabiltyMaxNotify 3
#define kExchangeTabIndex 2


@interface CandyStoreAppDelegate()

@property (nonatomic, retain) ProductBuilderService *productBuilderService;
@property (nonatomic, retain) TransactionReceiptService *transactionReceiptService;

- (void)alertUserHasNotPurchasedExchange;
- (void)reachabilityChanged:(NSNotification *)note;
- (BOOL)shouldAlertForReachabilityChanged;

@end


@implementation CandyStoreAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize candyShopViewController;
@synthesize internetReach;
@synthesize productBuilderService;
@synthesize transactionReceiptService;


#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[window release];
	[tabBarController release];
	[candyShopViewController release];
	[internetReach release];
	[productBuilderService release];
	[transactionReceiptService release];
    [super dealloc];
}


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifer];
	[self reachabilityChanged:nil];
	
	
	TransactionReceiptService *transService = [[TransactionReceiptService alloc] init];
	[self setTransactionReceiptService:transService];
	[transService beginObserving];
	[transService release];
	
	
	[window setRootViewController:tabBarController];
	[window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	[service reset];
	[service release];

//	[self updateProducts];
}


#pragma mark UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
	
	int index = [aTabBarController.viewControllers indexOfObject:viewController];
	if (index != kExchangeTabIndex) return YES;

// TODO: redo this
//	if ([CandyShopService hasExchange]) {
//		return YES;
//	}
	
	[self alertUserHasNotPurchasedExchange];
	return NO;
}


#pragma mark ProductBuilderServiceDelegate
- (void)productBuilderServiceDidUpdate:(ProductBuilderService *)sender {
	
	[candyShopViewController completeRefreshing];
}

- (void)productBuilderServiceDidFail:(ProductBuilderService *)sender {
	
	[candyShopViewController presentDataError:NSLocalizedString(@"Candy Store Is Unavailable", @"Candy Store Is Unavailable")];
}


#pragma mark -
#pragma mark CandyStoreAppDelegate
#pragma mark Public Messages
- (BOOL)canReachInternet {
	return (internetReach.currentReachabilityStatus != NotReachable);
}

- (void)updateProducts {
	
	[candyShopViewController beginRefreshing];
	
	//  just quit if the local service exists and it is not in status unknown, idle, or failed.
	if (productBuilderService && (
								  (productBuilderService.status != ProductBuilderServiceStatusUnknown)
								  && (productBuilderService.status != ProductBuilderServiceStatusIdle)
								  && (productBuilderService.status != ProductBuilderServiceStatusFailed)
								  )
		) return;
	
	ProductBuilderService *service = [[ProductBuilderService alloc] init];
	[self setProductBuilderService:service];
	[service setDelegate:self];
	[service beginBuildingProducts:[ModelCore sharedManager].managedObjectContext];
	[service release];
}


#pragma mark IBAction
- (IBAction)updateProducts:(id)sender {
	
	[self updateProducts];
}


#pragma mark Private Extension
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

