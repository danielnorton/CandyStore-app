//
//  ReceiptVerificationLocalService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ReceiptVerificationLocalService.h"
#import "PurchaseRepository.h"
#import "ProductRepository.h"
#import "NSObject+remoteErrorToApp.h"


@interface ReceiptVerificationLocalService()

@property (nonatomic, assign) int verifications;

@end


@implementation ReceiptVerificationLocalService


#pragma mark -
#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	
	[self passFailedAuthenticationNotificationToAppDelegate:sender];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	
	[self passTimeoutNotificationToAppDelegate:sender];
}


#pragma mark ReceiptVerificationRemoteServiceDelegate
- (void)receiptVerificationRemoteService:(ReceiptVerificationRemoteService *)sender
						  didReceiveCode:(ReceiptVerificationRemoteServiceCode)code
							 forPurchase:(Purchase *)purchase {
	
	switch (code) {
		case ReceiptVerificationRemoteServiceCodeFailedInvalidLocalData:
		case ReceiptVerificationRemoteServiceCodeFailedNonAutoRenewSubscription: {
			
			[self deleteFailedPurchase:purchase];
			break;
		}
			
		case ReceiptVerificationRemoteServiceCodeSubscriptionExpired: {
			
			[self markPurchase:purchase asExpired:YES];
			break;
		}
			
		case ReceiptVerificationRemoteServiceCodeSuccess:
		default: {
			
			[self markPurchase:purchase asExpired:NO];
			break;
		}
	}
	
	[self decrementVerificationCount];
}

- (void)receiptVerificationRemoteService:(ReceiptVerificationRemoteService *)sender
					  didFailForPurchase:(Purchase *)purchase {
	
	[self decrementVerificationCount];
}


#pragma mark -
#pragma mark ReceiptVerificationLocalService
- (void)verifyAllPurchases {
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSArray *all = [repo fetchAll];
	_verifications = all.count;

	if (all.count == 0) {

		[self notifyDelegateDidComplete];
		return;
	}

	[all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		Purchase *purchase = (Purchase *)obj;
		ReceiptVerificationRemoteService *service = [[ReceiptVerificationRemoteService alloc] init];
		[service setDelegate:self];
		[service beginVerifyPurchase:purchase];
	}];
}


#pragma mark Private Messages
- (void)deleteFailedPurchase:(Purchase *)purchase {
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:purchase.managedObjectContext];
	[repo removePurchaseFromProduct:purchase];
	[repo save:nil];
	
	[self notifyDelegateDidDeletePurchase];
}

- (void)markPurchase:(Purchase *)purchase asExpired:(BOOL)expired {

	[purchase setIsExpired:expired];
	[purchase.managedObjectContext save:nil];
}

- (void)decrementVerificationCount {
	
	_verifications--;
	if (_verifications <= 0) {
		
		[self notifyDelegateDidComplete];
	}
}

- (void)notifyDelegateDidDeletePurchase {
	
	if (![_delegate conformsToProtocol:@protocol(ReceiptVerificationLocalServiceDelegate)]) return;
	[_delegate receiptVerificationLocalServiceDidDeletePurchase:self];
}

- (void)notifyDelegateDidComplete {
	
	if (![_delegate conformsToProtocol:@protocol(ReceiptVerificationLocalServiceDelegate)]) return;
	[_delegate receiptVerificationLocalServiceDidComplete:self];
}


@end

