//
//  ExchangeAddCreditRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RemoteServiceBase.h"
#import "Model.h"


@class ExchangeAddCreditRemoteService;

@protocol ExchangeAddCreditRemoteServiceDelegate <NSObject, RemoteServiceDelegate>

- (void)exchangeAddCreditRemoteServiceDidAddCredit:(ExchangeAddCreditRemoteService *)sender;

@optional
- (void)exchangeAddCreditRemoteServiceFailedAddingCredit:(ExchangeAddCreditRemoteService *)sender;

@end


@interface ExchangeAddCreditRemoteService : RemoteServiceBase

- (void)beginAddingCreditFromPurchase:(Purchase *)purchase;

@end

