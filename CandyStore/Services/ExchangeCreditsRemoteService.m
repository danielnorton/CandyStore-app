//
//  ExchangeCreditsRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeCreditsRemoteService.h"
#import "EndpointService.h"
#import "PurchaseRepository.h"
#import "ExchangeItemRepository.h"
#import "CandyShopService.h"


@interface ExchangeCreditsRemoteService()

- (void)notifyDelegateSucceededRefreshing;
- (void)notifyDelegateFailedRefreshing;

@end


@implementation ExchangeCreditsRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
	
	NSDictionary *response = [sender.json objectAtIndex:0];
	int code = [[response objectForKey:@"code"] integerValue];
	if (code != 0) {
		
		[self notifyDelegateFailedRefreshing];
		return;
	}
	
	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	ExchangeItemRepository *repo = [[ExchangeItemRepository alloc] initWithContext:context];
	
	int newCreditCount = [[response valueForKeyPath:@"credits"] integerValue];
	[repo setOrCreateCreditsFromQuantity:newCreditCount];
	
	NSError *error = nil;
	if (![context save:&error]) {
		
		[context rollback];
		[self notifyDelegateFailedRefreshing];
		return;
	}
	
	[self notifyDelegateSucceededRefreshing];
}

- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender {
	
	[self notifyDelegateFailedRefreshing];
}


#pragma mark -
#pragma mark ExchangeCreditsRemoteService
- (void)beginRefreshingCreditCount {
	
	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:context];
	Purchase *exchange = [repo exchangePurchase];
	
	if (!exchange) {
		
		[self notifyDelegateFailedRefreshing];
		return;
	}
	
	
	NSString *basePath = [EndpointService exchangePath];
	NSString *path = [basePath stringByAppendingPathComponent:exchange.transactionIdentifier];
	
	[self setMethod:HTTPRequestServiceMethodGet];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:nil withUserData:nil];
}


#pragma mark Private Extension
- (void)notifyDelegateSucceededRefreshing {
	
	id<ExchangeCreditsRemoteServiceDelegate> del = (id<ExchangeCreditsRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeCreditsRemoteServiceDelegate)]) return;
	[del exchangeCreditsRemoteServiceDidRefreshCreditCount:self];
}

- (void)notifyDelegateFailedRefreshing {
	
	id<ExchangeCreditsRemoteServiceDelegate> del = (id<ExchangeCreditsRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeCreditsRemoteServiceDelegate)]) return;
	[del exchangeCreditsRemoteServiceFailedRefreshingCreditCount:self];
}


@end


