//
//  ExchangeAddCreditRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeAddCreditRemoteService.h"
#import "EndpointService.h"
#import "NSString+base64.h"
#import "PurchaseRepository.h"
#import "ExchangeItemRepository.h"
#import "CandyShopService.h"


@interface ExchangeAddCreditRemoteService()

- (void)notifyDelegateSucceededAdding;
- (void)notifyDelegateFailedAdding;

@end


@implementation ExchangeAddCreditRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
		
	NSDictionary *response = [sender.json objectAtIndex:0];
	int code = [[response objectForKey:@"code"] integerValue];
	if (code != 0) {
		
		[self notifyDelegateFailedAdding];
		return;
	}
	
	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	ExchangeItemRepository *repo = [[ExchangeItemRepository alloc] initWithContext:context];
	
	int newCreditCount = [[response valueForKeyPath:@"exchange.credits"] integerValue];
	[repo setOrCreateCreditsFromQuantity:newCreditCount];
	
	Purchase *purchase = (Purchase *)[context objectWithID:sender.userData];
	
	[context deleteObject:purchase];
	
	NSError *error = nil;
	if (![context save:&error]) {
		
		[context rollback];
		[self notifyDelegateFailedAdding];
		return;
	}
	
	[self notifyDelegateSucceededAdding];
}

- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender {
	
	[self notifyDelegateFailedAdding];
}


#pragma mark -
#pragma mark ExchangeAddCreditRemoteService
- (void)beginAddingCreditFromPurchase:(Purchase *)purchase {
	
	if (![purchase.product.internalKey isEqualToString:InternalKeyCandy]) return;
	
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:purchase.managedObjectContext];
	NSData *exchangeReceipt = [repo exchangeReceipt];
	[repo release];
	
	if (!exchangeReceipt) return;
	
	
	NSString *path = [EndpointService exchangePath];
	NSString *exchangeEncoded = [NSString base64StringFromData:exchangeReceipt length:exchangeReceipt.length];
	NSDictionary *exchangeTransfer = [NSDictionary dictionaryWithObject:exchangeEncoded forKey:@"receipt"];
	
	NSString *candyEncoded = [NSString base64StringFromData:purchase.receipt length:purchase.receipt.length];
	NSDictionary *candyTransfer = [NSDictionary dictionaryWithObjectsAndKeys:
								   candyEncoded, @"receipt",
								   purchase.productIdentifier, @"productIdentifier", nil];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							exchangeTransfer, @"exchange",
							candyTransfer, @"candy", nil];
	
	[self setMethod:HTTPRequestServiceMethodPutJson];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:params withUserData:purchase.objectID];	
}


#pragma mark Private Extension
- (void)notifyDelegateSucceededAdding {
	
	id<ExchangeAddCreditRemoteServiceDelegate> del = (id<ExchangeAddCreditRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeAddCreditRemoteServiceDelegate)]) return;
	[del exchangeAddCreditRemoteServiceDidAddCredit:self];
}

- (void)notifyDelegateFailedAdding {
	
	id<ExchangeAddCreditRemoteServiceDelegate> del = (id<ExchangeAddCreditRemoteServiceDelegate>)self.delegate;
	if (![del respondsToSelector:@selector(exchangeAddCreditRemoteServiceFailedAddingCredit:)]) return;
	[del exchangeAddCreditRemoteServiceFailedAddingCredit:self];
}


@end

