//
//  AppProductRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RemoteServiceBase.h"


@class AppProductRemoteService;

@protocol AppProductRemoteServiceDelegate <NSObject, RemoteServiceDelegate>

- (void)appProductRemoteService:(AppProductRemoteService *)sender didCompleteRetreiveProducts:(NSArray *)products;
- (void)appProductRemoteServiceDidFailRetreiveProducts:(AppProductRemoteService *)sender;

@end


@interface AppProductRemoteService : RemoteServiceBase

- (void)beginRetreiveProducts;

@end
