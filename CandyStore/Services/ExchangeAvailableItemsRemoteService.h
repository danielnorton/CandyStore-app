//
//  ExchangeAvailableItemsRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RemoteServiceBase.h"
#import "Model.h"


@class ExchangeAvailableItemsRemoteService;

@protocol ExchangeAvailableItemsRemoteServiceDelegate <NSObject, RemoteServiceDelegate>

- (void)exchangeAvailableItemsRemoteServiceDidRefreshAvailableItems:(ExchangeAvailableItemsRemoteService *)sender;
- (void)exchangeAvailableItemsRemoteServiceFailedRefreshingAvailableItems:(ExchangeAvailableItemsRemoteService *)sender;

@end

@interface ExchangeAvailableItemsRemoteService : RemoteServiceBase

- (void)beginRefreshingAvailableItems;

@end
