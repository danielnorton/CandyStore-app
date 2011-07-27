//
//  CandyStoreAppDelegate.h
//  CandyStore
//
//  Created by Daniel Norton on 7/22/11.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "Reachability.h"
#import "ProductBuilderService.h"

@interface CandyStoreAppDelegate : NSObject
<UIApplicationDelegate, UITabBarControllerDelegate,
ProductBuilderServiceDelegate>


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, readonly) Reachability *internetReach;

- (BOOL)canReachInternet;
- (void)updateProducts;

@end

