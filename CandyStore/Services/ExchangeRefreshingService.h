//
//  ExchangeRefreshingService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//


#import "ExchangeCreditsRemoteService.h"
#import "ExchangeAvailableItemsRemoteService.h"


typedef NS_ENUM(uint, ExchangeRefreshingServiceStatus) {
	
	ExchangeRefreshingServiceStatusUnknown,
	ExchangeRefreshingServiceStatusCredits,
	ExchangeRefreshingServiceStatusAvailableItems,
	ExchangeRefreshingServiceStatusFailed,
	ExchangeRefreshingServiceStatusIdle
	
};

@class ExchangeRefreshingService;

@protocol ExchangeRefreshingServiceDelegate <NSObject>

- (void)exchangeRefreshingServiceDidRefresh:(ExchangeRefreshingService *)sender;
- (void)exchangeRefreshingServiceFailedRefresh:(ExchangeRefreshingService *)sender;

@end

@interface ExchangeRefreshingService : NSObject
<ExchangeCreditsRemoteServiceDelegate, ExchangeAvailableItemsRemoteServiceDelegate>

@property (nonatomic, weak) id<ExchangeRefreshingServiceDelegate> delegate;
@property (nonatomic, readonly) ExchangeRefreshingServiceStatus status;

- (void)beginRefreshing;

@end
