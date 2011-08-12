//
//  CandyStoreAppDelegate.h
//  CandyStore
//
//  Created by Daniel Norton on 7/22/11.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "Reachability.h"
#import "ProductBuilderService.h"
#import "CandyShopViewController.h"
#import "CandyExchangeViewController.h"


@interface CandyStoreAppDelegate : NSObject
<UIApplicationDelegate, UITabBarControllerDelegate,
ProductBuilderServiceDelegate>


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet CandyShopViewController *candyShopViewController;
@property (nonatomic, retain) IBOutlet CandyExchangeViewController *candyExchangeViewController;
@property (nonatomic, retain) IBOutlet UITabBarItem *myJarTabBarItem;

@property (nonatomic, readonly) Reachability *internetReach;

- (BOOL)canReachInternet;
- (void)updateProducts;
- (void)updateExchange;

@end

