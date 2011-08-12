//
//  ExchangeRefreshingService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeRefreshingService.h"
#import "NSObject+remoteErrorToApp.h"


@interface ExchangeRefreshingService()

- (void)setStatus:(ExchangeRefreshingServiceStatus)status;
- (void)beginRefreshingAvailableItems;
- (void)notifyDelegateDidRefresh;
- (void)notifyDelegateFailedRefresh;

@end

@implementation ExchangeRefreshingService


@synthesize delegate;
@synthesize status;


#pragma mark -
#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	[self notifyDelegateFailedRefresh];
	[self passFailedAuthenticationNotificationToAppDelegate:sender];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	[self notifyDelegateFailedRefresh];
	[self passTimeoutNotificationToAppDelegate:sender];
}


#pragma mark ExchangeCreditsRemoteServiceDelegate
- (void)exchangeCreditsRemoteServiceDidRefreshCreditCount:(ExchangeCreditsRemoteService *)sender {
	
	[self beginRefreshingAvailableItems];
}

- (void)exchangeCreditsRemoteServiceFailedRefreshingCreditCount:(ExchangeCreditsRemoteService *)sender {
	
	[self notifyDelegateFailedRefresh];
}


#pragma mark ExchangeAvailableItemsRemoteServiceDelegate
- (void)exchangeAvailableItemsRemoteServiceDidRefreshAvailableItems:(ExchangeAvailableItemsRemoteService *)sender {
	
	[self notifyDelegateDidRefresh];
}

- (void)exchangeAvailableItemsRemoteServiceFailedRefreshingAvailableItems:(ExchangeAvailableItemsRemoteService *)sender {
	
	[self notifyDelegateFailedRefresh];
}


#pragma mark -
#pragma mark ExchangeRefreshingService
- (void)beginRefreshing {
	
	[self setStatus:ExchangeRefreshingServiceStatusCredits];
	
	ExchangeCreditsRemoteService *service = [[ExchangeCreditsRemoteService alloc] init];
	[service setDelegate:self];
	[service beginRefreshingCreditCount];
	[service release];
}


#pragma mark Private Extension
- (void)setStatus:(ExchangeRefreshingServiceStatus)aStatus {
	
	status = aStatus;
	NSLog(@"ExchangeRefreshingService status: %d", status);
}

- (void)beginRefreshingAvailableItems {
	
	[self setStatus:ExchangeRefreshingServiceStatusAvailableItems];
	
	ExchangeAvailableItemsRemoteService *service = [[ExchangeAvailableItemsRemoteService alloc] init];
	[service setDelegate:self];
	[service beginRefreshingAvailableItems];
	[service release];
}

- (void)notifyDelegateDidRefresh {
	
	[self setStatus:ExchangeRefreshingServiceStatusIdle];
	
	if (![delegate conformsToProtocol:@protocol(ExchangeRefreshingServiceDelegate)]) return;
	[delegate exchangeRefreshingServiceDidRefresh:self];
}

- (void)notifyDelegateFailedRefresh {
	
	[self setStatus:ExchangeRefreshingServiceStatusFailed];
	
	if (![delegate conformsToProtocol:@protocol(ExchangeRefreshingServiceDelegate)]) return;
	[delegate exchangeRefreshingServiceFailedRefresh:self];
}


@end

