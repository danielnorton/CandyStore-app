//
//  ReceiptVerificationRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ReceiptVerificationRemoteService.h"
#import "EndpointService.h"
#import "CandyShopService.h"
#import "NSString+base64.h"


@interface ReceiptVerificationRemoteService()

- (void)notifyDelegateDidReceiveCode:(ReceiptVerificationRemoteServiceCode)code forPurchase:(Purchase *)purchase;
- (void)notifyDelegateDidFailVerificationForPurchase:(Purchase *)purchase;

@end


@implementation ReceiptVerificationRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
	
	NSDictionary *response = [sender.json objectAtIndex:0];
	ReceiptVerificationRemoteServiceCode code = [[response objectForKey:@"code"] integerValue];
	NSString *transactionId = [response objectForKey:@"transactionIdentifier"];
	
	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	Purchase *purchase = (Purchase *)[context objectWithID:sender.userData];
	
	if (![purchase.transactionIdentifier isEqualToString:transactionId]) {
		
		code = ReceiptVerificationRemoteServiceCodeFailedInvalidLocalData;
		
	} else if ((code != ReceiptVerificationRemoteServiceCodeSuccess) && (![purchase.product.parent.internalKey isEqualToString:InternalKeyExchange])) {
	
		code = ReceiptVerificationRemoteServiceCodeFailedNonAutoRenewSubscription;
	}
	
	[self notifyDelegateDidReceiveCode:code forPurchase:purchase];
}

- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender {

	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	Purchase *purchase = (Purchase *)[context objectWithID:sender.userData];
	
	[self notifyDelegateDidFailVerificationForPurchase:purchase];
}


#pragma mark -
#pragma mark ReceiptVerificationRemoteService
- (void)beginVerifyPurchase:(Purchase *)purchase {
	
	NSString *path = [EndpointService receiptVerificationPath];
	NSString *encoded = [NSString base64StringFromData:purchase.receipt length:purchase.receipt.length];
	
	NSString *internalKey = purchase.product.parent
	? purchase.product.parent.internalKey
	: purchase.product.internalKey;
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							encoded, @"receipt",
							internalKey, @"type", nil];
	
	[self setMethod:HTTPRequestServiceMethodPostJson];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:params withUserData:purchase.objectID];
}


#pragma mark Private Extension
- (void)notifyDelegateDidReceiveCode:(ReceiptVerificationRemoteServiceCode)code forPurchase:(Purchase *)purchase {
	
	id<ReceiptVerificationRemoteServiceDelegate> del = (id<ReceiptVerificationRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ReceiptVerificationRemoteServiceDelegate)]) return;	
	[del receiptVerificationRemoteService:self didReceiveCode:code forPurchase:purchase];
}

- (void)notifyDelegateDidFailVerificationForPurchase:(Purchase *)purchase {
	
	id<ReceiptVerificationRemoteServiceDelegate> del = (id<ReceiptVerificationRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(ReceiptVerificationRemoteServiceDelegate)]) return;
	[del receiptVerificationRemoteService:self didFailForPurchase:purchase];
}


@end

