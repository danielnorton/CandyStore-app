//
//  ExchangeRefreshingService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeRefreshingService.h"
#import "NSObject+remoteErrorToApp.h"


@implementation ExchangeRefreshingService


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
}


#pragma mark Private Messages
- (void)setStatus:(ExchangeRefreshingServiceStatus)aStatus {
	
	_status = aStatus;
	NSLog(@"ExchangeRefreshingService status: %d", aStatus);
}

- (void)beginRefreshingAvailableItems {
	
	[self setStatus:ExchangeRefreshingServiceStatusAvailableItems];
	
	ExchangeAvailableItemsRemoteService *service = [[ExchangeAvailableItemsRemoteService alloc] init];
	[service setDelegate:self];
	[service beginRefreshingAvailableItems];
}

- (void)notifyDelegateDidRefresh {
	
	[self setStatus:ExchangeRefreshingServiceStatusIdle];
	
	if (![_delegate conformsToProtocol:@protocol(ExchangeRefreshingServiceDelegate)]) return;
	[_delegate exchangeRefreshingServiceDidRefresh:self];
}

- (void)notifyDelegateFailedRefresh {
	
	[self setStatus:ExchangeRefreshingServiceStatusFailed];
	
	if (![_delegate conformsToProtocol:@protocol(ExchangeRefreshingServiceDelegate)]) return;
	[_delegate exchangeRefreshingServiceFailedRefresh:self];
}


@end

