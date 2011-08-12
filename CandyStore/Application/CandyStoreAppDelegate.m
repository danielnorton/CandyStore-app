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
#import "TransactionReceiptService.h"
#import "CandyShopService.h"
#import "Model.h"
#import "ReceiptVerificationLocalService.h"


#define kReachabiltyMaxNotify 3
#define kExchangeTabIndex 2


@interface CandyStoreAppDelegate()

@property (nonatomic, retain) ProductBuilderService *productBuilderService;
@property (nonatomic, retain) TransactionReceiptService *transactionReceiptService;
@property (nonatomic, retain) ExchangeRefreshingService *exchangeRefreshingService;
@property (nonatomic, retain) ReceiptVerificationLocalService *receiptVerificationLocalService;

- (void)verifyPurchases;
- (BOOL)canRestoreOrRefresh;
- (void)alertUserHasNotPurchasedExchange;
- (void)reachabilityChanged:(NSNotification *)note;
- (BOOL)shouldAlertForReachabilityChanged;
- (void)updateJarTabImage;

@end


@implementation CandyStoreAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize candyJarViewController;
@synthesize candyShopViewController;
@synthesize candyExchangeViewController;
@synthesize internetReach;
@synthesize myJarTabBarItem;
@synthesize productBuilderService;
@synthesize transactionReceiptService;
@synthesize exchangeRefreshingService;
@synthesize receiptVerificationLocalService;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[window release];
	[tabBarController release];
	[candyJarViewController release];
	[candyShopViewController release];
	[candyExchangeViewController release];
	[internetReach release];
	[myJarTabBarItem release];
	[productBuilderService release];
	[transactionReceiptService release];
	[exchangeRefreshingService release];
	[receiptVerificationLocalService release];
    [super dealloc];
}


#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
	internetReach = [[Reachability reachabilityForInternetConnection] retain];
	[internetReach startNotifer];
	[self reachabilityChanged:nil];
	
		
	void (^respondToReceiptRestoreNotification)(NSNotification *) = ^(NSNotification *notification) {
		
		[candyJarViewController resetShouldEnableExchangeButtons];
		[self updateProducts];
	};
	
	void (^respondToReceiptPurchaseNotification)(NSNotification *) = ^(NSNotification *notification) {
		
		[candyJarViewController resetShouldEnableExchangeButtons];
		[self updateJarTabImage];
	};	
	
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];	
	[center addObserverForName:TransactionReceiptServiceRestoreCompletedNotification
						object:nil
						 queue:nil
					usingBlock:respondToReceiptRestoreNotification];
	
	[center addObserverForName:TransactionReceiptServiceRestoreFailedNotification
						object:nil
						 queue:nil
					usingBlock:respondToReceiptRestoreNotification];
	
	[center addObserverForName:TransactionReceiptServiceCompletedNotification
						object:nil
						 queue:nil
					usingBlock:respondToReceiptPurchaseNotification];
	
	
	TransactionReceiptService *transService = [[TransactionReceiptService alloc] init];
	[self setTransactionReceiptService:transService];
	[transService beginObserving];
	[transService release];
	
	
	[window setRootViewController:tabBarController];
	[window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	
	[self updateJarTabImage];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	[service reset];
	[service release];

	[self updateProducts];
}


#pragma mark UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)aTabBarController shouldSelectViewController:(UIViewController *)viewController {
	
	int index = [aTabBarController.viewControllers indexOfObject:viewController];
	if (index != kExchangeTabIndex) return YES;

	if ([CandyShopService canSeeExchangeTab]) return YES;
	
	[self alertUserHasNotPurchasedExchange];
	
	return NO;
}


#pragma mark ProductBuilderServiceDelegate
- (void)productBuilderServiceDidUpdate:(ProductBuilderService *)sender {
	
	[candyShopViewController completeRefreshing];
	[self updateJarTabImage];
	[self verifyPurchases];
}

- (void)productBuilderServiceDidFail:(ProductBuilderService *)sender {
	
	[candyShopViewController presentDataError:NSLocalizedString(@"Candy Store Is Unavailable", @"Candy Store Is Unavailable")];
}


#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	[self popup:NSLocalizedString(@"Candy Store server authentication failed",
								  @"Candy Store server authentication failed")];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	[self popup:NSLocalizedString(@"Request timed out", @"Request timed out")];
}


#pragma mark ExchangeRefreshingServiceDelegate
- (void)exchangeRefreshingServiceDidRefresh:(ExchangeRefreshingService *)sender {
	
	[candyExchangeViewController completeRefreshing];
}

- (void)exchangeRefreshingServiceFailedRefresh:(ExchangeRefreshingService *)sender {
	
	[candyExchangeViewController presentDataError:NSLocalizedString(@"Candy Exchange Is Unavailable", @"Candy Exchange Is Unavailable")];
}


#pragma mark ReceiptVerificationLocalServiceDelegate
- (void)receiptVerificationLocalServiceDidDeletePurchase:(ReceiptVerificationLocalService *)sender {
	
	[self updateJarTabImage];
}

- (void)receiptVerificationLocalServiceDidComplete:(ReceiptVerificationLocalService *)sender {
	
	[candyJarViewController resetShouldEnableExchangeButtons];
	[self updateExchange];
}


#pragma mark -
#pragma mark CandyStoreAppDelegate
#pragma mark Public Messages
- (BOOL)canReachInternet {
	return (internetReach.currentReachabilityStatus != NotReachable);
}

- (void)updateProducts {

	// can be called from Candy Shop view controller and waking App Delegate
	// coordinate table animations from here
	
	if (![self canRestoreOrRefresh]) return;
	
	[candyShopViewController beginRefreshing];
	[candyExchangeViewController beginRefreshing];
	
	ProductBuilderService *service = [[ProductBuilderService alloc] init];
	[service setDelegate:self];
	[self setProductBuilderService:service];
	[service beginBuildingProducts:[ModelCore sharedManager].managedObjectContext];
	[service release];
}

- (void)updateExchange {
	
	if (![self canRestoreOrRefresh]) return;
	
	[candyExchangeViewController beginRefreshing];
	
	ExchangeRefreshingService *service = [[ExchangeRefreshingService alloc] init];
	[service setDelegate:self];
	[self setExchangeRefreshingService:service];
	[service beginRefreshing];
	[service release];
}


#pragma mark IBAction
- (IBAction)updateProducts:(id)sender {
	
	[self updateProducts];
}

- (IBAction)updateExchange:(id)sender {
	
	[self updateExchange];
}

- (IBAction)restoreTransactions:(id)sender {
	
	// can only be called from Candy Shop view controller, but it's here for consistancy
	
	if (![self canRestoreOrRefresh]) return;
	
	[candyShopViewController beginRefreshing];
	[candyExchangeViewController beginRefreshing];
	[transactionReceiptService restoreTransactions];
}


#pragma mark Private Extension
- (void)verifyPurchases {

	ReceiptVerificationLocalService *service = [[ReceiptVerificationLocalService alloc] init];
	[service setDelegate:self];
	[self setReceiptVerificationLocalService:service];
	[service verifyAllPurchases];
	[service release];
}

- (BOOL)canRestoreOrRefresh {

	BOOL canRefreshProducts = (productBuilderService.status == ProductBuilderServiceStatusUnknown)
	|| (productBuilderService.status == ProductBuilderServiceStatusIdle)
	|| (productBuilderService.status == ProductBuilderServiceStatusFailed);

	BOOL canRefreshExchange = (exchangeRefreshingService.status == ExchangeRefreshingServiceStatusUnknown)
	|| (exchangeRefreshingService.status == ExchangeRefreshingServiceStatusIdle)
	|| (exchangeRefreshingService.status == ExchangeRefreshingServiceStatusFailed);

	return canRefreshProducts && canRefreshExchange;
}

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

- (void)updateJarTabImage {
	
	UIImage *icon = [CandyShopService hasBigCandyJar]
	? [UIImage imageNamed:@"bigJarTab"]
	: [UIImage imageNamed:@"smallJarTab"];
	
	[myJarTabBarItem setImage:icon];
}


@end

