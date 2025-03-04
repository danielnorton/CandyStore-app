//
//  ExchangeAddCreditRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeAddCreditRemoteService.h"
#import "EndpointService.h"
#import "NSData+Base64.h"
#import "PurchaseRepository.h"
#import "ExchangeItemRepository.h"
#import "CandyShopService.h"


@implementation ExchangeAddCreditRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
		
	NSDictionary *response = (sender.json)[0];
	_code = [response[@"code"] integerValue];
	if (_code != ReceiptVerificationRemoteServiceCodeSuccess) {
		
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
	NSData *exchangeReceipt = [repo exchangePurchase].receipt;
	
	if (!exchangeReceipt) return;
	
	
	NSString *path = [EndpointService exchangePath];
	NSString *exchangeEncoded = [exchangeReceipt base64EncodedString];
	NSDictionary *exchangeTransfer = @{@"receipt": exchangeEncoded};
	
	NSString *candyEncoded = [purchase.receipt base64EncodedString];
	NSDictionary *candyTransfer = @{@"receipt": candyEncoded,
								   @"productIdentifier": purchase.productIdentifier};
	
	NSDictionary *params = @{@"exchange": exchangeTransfer,
							@"candy": candyTransfer};
	
	[self setMethod:HTTPRequestServiceMethodPutJson];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:params withUserData:purchase.objectID];
}


#pragma mark Private Messages
- (void)notifyDelegateSucceededAdding {
	
	id<ExchangeAddCreditRemoteServiceDelegate> del = (id<ExchangeAddCreditRemoteServiceDelegate>)self.delegate;
	if (![del respondsToSelector:@selector(exchangeAddCreditRemoteServiceDidAddCredit:)]) return;
	[del exchangeAddCreditRemoteServiceDidAddCredit:self];
}

- (void)notifyDelegateFailedAdding {
	
	id<ExchangeAddCreditRemoteServiceDelegate> del = (id<ExchangeAddCreditRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeAddCreditRemoteServiceDelegate)]) return;
	[del exchangeAddCreditRemoteServiceFailedAddingCredit:self];
}


@end

