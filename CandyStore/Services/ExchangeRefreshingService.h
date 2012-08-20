//
//  ExchangeRefreshingService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//


#import "ExchangeCreditsRemoteService.h"
#import "ExchangeAvailableItemsRemoteService.h"


typedef enum {
	
	ExchangeRefreshingServiceStatusUnknown,
	ExchangeRefreshingServiceStatusCredits,
	ExchangeRefreshingServiceStatusAvailableItems,
	ExchangeRefreshingServiceStatusFailed,
	ExchangeRefreshingServiceStatusIdle
	
} ExchangeRefreshingServiceStatus;

@class ExchangeRefreshingService;

@protocol ExchangeRefreshingServiceDelegate <NSObject>

- (void)exchangeRefreshingServiceDidRefresh:(ExchangeRefreshingService *)sender;
- (void)exchangeRefreshingServiceFailedRefresh:(ExchangeRefreshingService *)sender;

@end

@interface ExchangeRefreshingService : NSObject
<ExchangeCreditsRemoteServiceDelegate, ExchangeAvailableItemsRemoteServiceDelegate>

@property (nonatomic, unsafe_unretained) id<ExchangeRefreshingServiceDelegate> delegate;
@property (nonatomic, readonly) ExchangeRefreshingServiceStatus status;

- (void)beginRefreshing;

@end
