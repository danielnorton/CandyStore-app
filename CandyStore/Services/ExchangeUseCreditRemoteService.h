//
//  ExchangeUseCreditRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RemoteServiceBase.h"
#import "Model.h"


@class ExchangeUseCreditRemoteService;

@protocol ExchangeUseCreditRemoteServiceDelegate <NSObject, RemoteServiceDelegate>

- (void)exchangeUseCreditRemoteServiceDidUseCredit:(ExchangeUseCreditRemoteService *)sender;
- (void)exchangeUseCreditRemoteServiceFailedUsingCredit:(ExchangeUseCreditRemoteService *)sender;

@end

@interface ExchangeUseCreditRemoteService : RemoteServiceBase

- (void)beginUseCreditForProduct:(Product *)product;

@end
