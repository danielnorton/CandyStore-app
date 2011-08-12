//
//  ExchangeAddCreditRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RemoteServiceBase.h"
#import "Model.h"
#import "ReceiptVerificationRemoteService.h"


@class ExchangeAddCreditRemoteService;

@protocol ExchangeAddCreditRemoteServiceDelegate <NSObject, RemoteServiceDelegate>

- (void)exchangeAddCreditRemoteServiceFailedAddingCredit:(ExchangeAddCreditRemoteService *)sender;

@optional
- (void)exchangeAddCreditRemoteServiceDidAddCredit:(ExchangeAddCreditRemoteService *)sender;

@end


@interface ExchangeAddCreditRemoteService : RemoteServiceBase

@property (nonatomic, readonly) ReceiptVerificationRemoteServiceCode code;

- (void)beginAddingCreditFromPurchase:(Purchase *)purchase;

@end

