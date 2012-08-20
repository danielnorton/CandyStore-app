//
//  ExchangeAvailableItemsRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeAvailableItemsRemoteService.h"
#import "ExchangeItemRepository.h"
#import "ProductRepository.h"
#import "EndpointService.h"


@interface ExchangeAvailableItemsRemoteService()

- (void)notifyDelegateSucceededRefreshing;
- (void)notifyDelegateFailedRefreshing;

@end


@implementation ExchangeAvailableItemsRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
	
	NSArray *response = sender.json;

	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	ExchangeItemRepository *repo = [[ExchangeItemRepository alloc] initWithContext:context];
	
	[response enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSDictionary *itemJson = (NSDictionary *)obj;
		NSString *productIdentifer = itemJson[@"key"];
		NSNumber *quantity = itemJson[@"value"];
		
		ExchangeItem *item = [repo createOrUpdateExchangeItemForProductIdentifier:productIdentifer];
		[item setQuantityAvailable:quantity];
	}];
	
	
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
- (void)beginRefreshingAvailableItems {
	
	NSString *path = [EndpointService exchangePath];
	
	[self setMethod:HTTPRequestServiceMethodGet];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:nil withUserData:nil];
}


#pragma mark Private Extension
- (void)notifyDelegateSucceededRefreshing {
	
	id<ExchangeAvailableItemsRemoteServiceDelegate> del = (id<ExchangeAvailableItemsRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeAvailableItemsRemoteServiceDelegate)]) return;
	[del exchangeAvailableItemsRemoteServiceDidRefreshAvailableItems:self];
}

- (void)notifyDelegateFailedRefreshing {
	
	id<ExchangeAvailableItemsRemoteServiceDelegate> del = (id<ExchangeAvailableItemsRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeAvailableItemsRemoteServiceDelegate)]) return;
	[del exchangeAvailableItemsRemoteServiceFailedRefreshingAvailableItems:self];
}


@end

