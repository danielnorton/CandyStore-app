//
//  ExchangeUseCreditRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeUseCreditRemoteService.h"
#import "ExchangeItemRepository.h"
#import "PurchaseRepository.h"
#import "EndpointService.h"
#import "NSData+Base64.h"
#import "CandyShopService.h"
#import "ReceiptVerificationRemoteService.h"


@interface ExchangeUseCreditRemoteService()

- (void)notifyDelegateSucceededUsing;
- (void)notifyDelegateFailedUsing;

@end


@implementation ExchangeUseCreditRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
	
	NSDictionary *response = (sender.json)[0];
	int code = [[response valueForKey:@"code"] integerValue];
	
	if (
		(code != ReceiptVerificationRemoteServiceCodeSuccess)
		&& (code != ReceiptVerificationRemoteServiceCodeSubscriptionExpired)) {
		
		[self notifyDelegateFailedUsing];
		return;
	}
	
	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	
	ExchangeItemRepository *exchangeItemRepo = [[ExchangeItemRepository alloc] initWithContext:context];
	ExchangeItem *credits = [exchangeItemRepo creditsItem];
	
	int newQuantity = [credits.quantityAvailable integerValue];
	newQuantity--;
	[credits setQuantityAvailable:@(newQuantity)];
	
	NSString *transactionIdentifier = [response valueForKeyPath:@"candy.transactionIdentifier"];
	NSString *rawReceipt = [response valueForKeyPath:@"candy.receipt"];
	NSData *receipt = [NSData dataFromBase64String:rawReceipt];
	
	Product *product = (Product *)[context objectWithID:sender.userData];
	int newQuantityAvailable = [product.exchangeItem.quantityAvailable integerValue];
	newQuantityAvailable--;
	[product.exchangeItem setQuantityAvailable:@(newQuantityAvailable)];
	
	PurchaseRepository *purchaseRepo = [[PurchaseRepository alloc] initWithContext:context];
	Purchase *purchase = [purchaseRepo addOrRetreivePurchaseForProduct:product withTransactionIdentifier:transactionIdentifier];
	
	[purchase setProductIdentifier:product.identifier];
	[purchase setReceipt:receipt];
	
	NSError *error = nil;
	if (![context save:&error]) {
		
		[context rollback];
		[self notifyDelegateFailedUsing];
		return;
	}
	
	[self notifyDelegateSucceededUsing];
}

- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender {
	
	[self notifyDelegateFailedUsing];
}


#pragma mark -
#pragma mark ExchangeUseCreditRemoteService
- (void)beginUseCreditForProduct:(Product *)product {

	if (![product.internalKey isEqualToString:InternalKeyCandy]) {
		
		[self notifyDelegateFailedUsing];
		return;
	}
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:product.managedObjectContext];
	NSData *exchangeReceipt = [repo exchangePurchase].receipt;
	
	if (!exchangeReceipt) {
		
		[self notifyDelegateFailedUsing];
		return;
	}
	
	
	NSString *path = [EndpointService exchangePath];
	NSString *exchangeEncoded = [exchangeReceipt base64EncodedString];
	NSDictionary *exchangeTransfer = @{@"receipt": exchangeEncoded};
	
	NSDictionary *candyTransfer = @{@"productIdentifier": product.identifier};
	
	NSDictionary *params = @{@"exchange": exchangeTransfer,
							@"candy": candyTransfer};
	
	[self setMethod:HTTPRequestServiceMethodPostJson];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:params withUserData:product.objectID];
}


#pragma mark Private Extension
- (void)notifyDelegateSucceededUsing {
	
	id<ExchangeUseCreditRemoteServiceDelegate> del = (id<ExchangeUseCreditRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeUseCreditRemoteServiceDelegate)]) return;
	[del exchangeUseCreditRemoteServiceDidUseCredit:self];
}

- (void)notifyDelegateFailedUsing {
	
	id<ExchangeUseCreditRemoteServiceDelegate> del = (id<ExchangeUseCreditRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ExchangeUseCreditRemoteServiceDelegate)]) return;
	[del exchangeUseCreditRemoteServiceFailedUsingCredit:self];
}


@end

