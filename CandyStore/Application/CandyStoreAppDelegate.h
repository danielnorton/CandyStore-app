//
//  CandyStoreAppDelegate.h
//  CandyStore
//
//  Created by Daniel Norton on 7/22/11.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "ProductBuilderService.h"
#import "CandyShopViewController.h"
#import "CandyExchangeViewController.h"
#import "CandyJarViewController.h"
#import "ExchangeRefreshingService.h"
#import "RemoteServiceBase.h"
#import "ReceiptVerificationLocalService.h"


@interface CandyStoreAppDelegate : NSObject
<UIApplicationDelegate, UITabBarControllerDelegate,
ProductBuilderServiceDelegate, ExchangeRefreshingServiceDelegate,
RemoteServiceDelegate, ReceiptVerificationLocalServiceDelegate>

@property (nonatomic, strong) UIWindow *window;

- (void)updateProducts;
- (void)updateExchange;
- (void)restoreTransactions;

@end

