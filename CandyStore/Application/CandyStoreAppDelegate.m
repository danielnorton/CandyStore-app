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
#import "TransactionReceiptService.h"
#import "CandyShopService.h"
#import "Model.h"
#import "ReceiptVerificationLocalService.h"
#import "ProductRepository.h"


#define kExchangeTabIndex 2


@interface CandyStoreAppDelegate()

@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) IBOutlet CandyJarViewController *candyJarViewController;
@property (nonatomic, strong) IBOutlet CandyShopViewController *candyShopViewController;
@property (nonatomic, strong) IBOutlet CandyExchangeViewController *candyExchangeViewController;
@property (nonatomic, strong) IBOutlet UITabBarItem *myJarTabBarItem;

@property (nonatomic, strong) ProductBuilderService *productBuilderService;
@property (nonatomic, strong) TransactionReceiptService *transactionReceiptService;
@property (nonatomic, strong) ExchangeRefreshingService *exchangeRefreshingService;
@property (nonatomic, strong) ReceiptVerificationLocalService *receiptVerificationLocalService;

@end


@implementation CandyStoreAppDelegate

#pragma mark -
#pragma mark UIApplicationDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	self.tabBarController = (UITabBarController *)_window.rootViewController;
	self.candyJarViewController = _tabBarController.viewControllers[0];
	self.myJarTabBarItem = _candyJarViewController.tabBarItem;
	self.candyShopViewController = (CandyShopViewController *)((UINavigationController *)_tabBarController.viewControllers[1]).topViewController;
	self.candyExchangeViewController = (CandyExchangeViewController *)((UINavigationController *)_tabBarController.viewControllers[2]).topViewController;
	
	void (^respondToReceiptRestoreNotification)(NSNotification *) = ^(NSNotification *notification) {
		
		[_candyJarViewController resetShouldEnableExchangeButtons];
		[self updateProducts];
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
					usingBlock:^(NSNotification *notification) {
						
						[_candyJarViewController resetShouldEnableExchangeButtons];
						[self updateJarTabImage];
					}];
	
	
	TransactionReceiptService *transService = [[TransactionReceiptService alloc] init];
	[self setTransactionReceiptService:transService];
	[transService beginObserving];

    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	[service reset];

	[self updateJarTabImage];
	
	if ([ProductBuilderService hasSignificantTimePassedSinceLastUpdate]) {
		
		[self updateProducts];
	}
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
	
	[self updateJarTabImage];
	[self verifyPurchases];
}

- (void)productBuilderServiceDidFail:(ProductBuilderService *)sender {
	
	[_candyShopViewController presentDataError:NSLocalizedString(@"Candy Store Is Unavailable", @"Candy Store Is Unavailable")];
	[_candyExchangeViewController presentDataError:NSLocalizedString(@"Candy Exchange Is Unavailable", @"Candy Exchange Is Unavailable")];
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
	
	[_candyExchangeViewController completeRefreshing];
}

- (void)exchangeRefreshingServiceFailedRefresh:(ExchangeRefreshingService *)sender {
	
	[_candyExchangeViewController presentDataError:NSLocalizedString(@"Candy Exchange Is Unavailable", @"Candy Exchange Is Unavailable")];
}


#pragma mark ReceiptVerificationLocalServiceDelegate
- (void)receiptVerificationLocalServiceDidDeletePurchase:(ReceiptVerificationLocalService *)sender {
	
	//[_candyShopViewController completeRefreshing]; // <-- may not belong here
	[self updateJarTabImage];
}

- (void)receiptVerificationLocalServiceDidComplete:(ReceiptVerificationLocalService *)sender {
	
	[_candyShopViewController completeRefreshing];
	[_candyJarViewController resetShouldEnableExchangeButtons];
	[self updateExchange];
}


#pragma mark -
#pragma mark CandyStoreAppDelegate
#pragma mark Public Messages
- (void)updateProducts {

	// can be called from Candy Shop view controller and waking App Delegate
	// coordinate table animations from here
	
	if (![self canRestoreOrRefresh]) return;
	
	[_candyShopViewController beginRefreshing];
	[_candyExchangeViewController beginRefreshing];
	
	[_productBuilderService setDelegate:nil];
	ProductBuilderService *service = [[ProductBuilderService alloc] init];
	[service setDelegate:self];
	[self setProductBuilderService:service];
	[service beginBuildingProducts:[ModelCore sharedManager].managedObjectContext];
}

- (void)updateExchange {
	
	if (![self canRestoreOrRefresh]) return;
	
	[_candyExchangeViewController beginRefreshing];
	
	[_exchangeRefreshingService setDelegate:nil];
	ExchangeRefreshingService *service = [[ExchangeRefreshingService alloc] init];
	[service setDelegate:self];
	[self setExchangeRefreshingService:service];
	[service beginRefreshing];
}

- (void)restoreTransactions {
	
	// can only be called from Candy Shop view controller, but it's here for consistancy
	
	if (![self canRestoreOrRefresh]) return;
	
	[_candyShopViewController beginRefreshing];
	[_candyExchangeViewController beginRefreshing];
	[_transactionReceiptService restoreTransactions];
}


#pragma mark IBAction
- (IBAction)updateProducts:(id)sender {
	
	[self updateProducts];
}

- (IBAction)updateExchange:(id)sender {
	
	[self updateExchange];
}


#pragma mark Private Messages
- (void)verifyPurchases {

	[_receiptVerificationLocalService setDelegate:nil];
	ReceiptVerificationLocalService *service = [[ReceiptVerificationLocalService alloc] init];
	[service setDelegate:self];
	[self setReceiptVerificationLocalService:service];
	[service verifyAllPurchases];
}

- (BOOL)canRestoreOrRefresh {

	BOOL canRefreshProducts = (_productBuilderService.status == ProductBuilderServiceStatusUnknown)
	|| (_productBuilderService.status == ProductBuilderServiceStatusIdle)
	|| (_productBuilderService.status == ProductBuilderServiceStatusFailed);

	BOOL canRefreshExchange = (_exchangeRefreshingService.status == ExchangeRefreshingServiceStatusUnknown)
	|| (_exchangeRefreshingService.status == ExchangeRefreshingServiceStatusIdle)
	|| (_exchangeRefreshingService.status == ExchangeRefreshingServiceStatusFailed);

	return canRefreshProducts && canRefreshExchange;
}

- (void)alertUserHasNotPurchasedExchange {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	
	if (!service.shouldNotify) {
		
		return;
	}
	
	service.counter++;
	[_tabBarController popup:service.message];
}

- (void)updateJarTabImage {
	
	UIImage *icon = [CandyShopService hasBigCandyJar]
	? [UIImage imageNamed:@"bigJarTab"]
	: [UIImage imageNamed:@"smallJarTab"];
	
	[_myJarTabBarItem setImage:icon];
}


@end

