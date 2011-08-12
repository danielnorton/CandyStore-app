//
//  ExchangeCreditsRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RemoteServiceBase.h"
#import "Model.h"


@class ExchangeCreditsRemoteService;

@protocol ExchangeCreditsRemoteServiceDelegate <NSObject, RemoteServiceDelegate>

- (void)exchangeCreditsRemoteServiceDidRefreshCreditCount:(ExchangeCreditsRemoteService *)sender;
- (void)exchangeCreditsRemoteServiceFailedRefreshingCreditCount:(ExchangeCreditsRemoteService *)sender;

@end


@interface ExchangeCreditsRemoteService : RemoteServiceBase

- (void)beginRefreshingCreditCount;

@end
