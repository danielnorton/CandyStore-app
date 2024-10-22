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
#import "NSData+Base64.h"


@implementation ReceiptVerificationRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
	
	NSDictionary *response = (sender.json)[0];
	ReceiptVerificationRemoteServiceCode code = [response[@"code"] integerValue];
	NSString *transactionId = response[@"transactionIdentifier"];
	
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
	NSString *encoded = [purchase.receipt base64EncodedString];
	
	NSString *internalKey = purchase.product.parent
	? purchase.product.parent.internalKey
	: purchase.product.internalKey;
	
	NSDictionary *params = @{@"receipt": encoded,
							@"type": internalKey};
	
	[self setMethod:HTTPRequestServiceMethodPostJson];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:params withUserData:purchase.objectID];
}


#pragma mark Private Messages
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

