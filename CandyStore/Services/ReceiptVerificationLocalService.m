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


NSString * const ReceiptVerificationDidVerifyPurchaseNotification = @"ReceiptVerificationDidVerifyPurchaseNotification";
NSString * const ReceiptVerificationWillDeletePurchaseNotification = @"ReceiptVerificationWillDeletePurchaseNotification";
NSString * const ReceiptVerificationDidDeletePurchaseNotification = @"ReceiptVerificationDidDeletePurchaseNotification";
NSString * const ReceiptVerificationWillExpireSubscriptionPurchaseNotification = @"ReceiptVerificationWillExpireSubscriptionPurchaseNotification";
NSString * const ReceiptVerificationDidExpireSubscriptionPurchaseNotification = @"ReceiptVerificationDidExpireSubscriptionPurchaseNotification";
NSString * const ReceiptVerificationPurchaseKey = @"ReceiptVerificationPurchaseKey";


@interface ReceiptVerificationLocalService()

- (void)deleteFailedPurchase:(Purchase *)purchase;
- (void)markPurchaseAsExpired:(Purchase *)purchase;
- (void)notifyName:(NSString *)name forPurchase:(Purchase *)purchase;

@end


@implementation ReceiptVerificationLocalService


#pragma mark -
#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	
	[self passFailedAuthenticationNotificationToAppDelegate:sender];
	[self release];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	
	[self passTimeoutNotificationToAppDelegate:sender];
	[self release];
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
			
			[self markPurchaseAsExpired:purchase];
			break;
		}
			
		case ReceiptVerificationRemoteServiceCodeSuccess: {
			
			[self notifyName:ReceiptVerificationDidVerifyPurchaseNotification forPurchase:purchase];
			break;
		}
			
		default:
			break;
	}
	
	[self release];
}

- (void)receiptVerificationRemoteService:(ReceiptVerificationRemoteService *)sender
					  didFailForPurchase:(Purchase *)purchase {
	
	[self release];
}


#pragma mark -
#pragma mark ReceiptVerificationLocalService
+ (void)verifyAllPurchases {

	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSArray *all = [repo fetchAll]; 
	[repo release];
	
	[all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		ReceiptVerificationLocalService *onesie = [[ReceiptVerificationLocalService alloc] init];
		Purchase *purchase = (Purchase *)obj;
		[onesie verifyPurchase:purchase];
		[onesie release];
	}];
}

- (void)verifyPurchase:(Purchase *)purchase {
	
	[self retain];
	
	ReceiptVerificationRemoteService *service = [[ReceiptVerificationRemoteService alloc] init];
	[service setDelegate:self];
	[service beginVerifyPurchase:purchase];
	[service release];
}


#pragma mark Private Extension
- (void)deleteFailedPurchase:(Purchase *)purchase {
	
	[self notifyName:ReceiptVerificationWillDeletePurchaseNotification forPurchase:purchase];
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:purchase.managedObjectContext];
	[repo removePurchaseFromProduct:purchase];
	[repo save:nil];
	[repo release];
	
	[self notifyName:ReceiptVerificationDidDeletePurchaseNotification forPurchase:nil];
}

- (void)markPurchaseAsExpired:(Purchase *)purchase {

	[self notifyName:ReceiptVerificationWillExpireSubscriptionPurchaseNotification forPurchase:purchase];
	
	[purchase setIsExpired:YES];
	[purchase.managedObjectContext save:nil];
	
	[self notifyName:ReceiptVerificationDidExpireSubscriptionPurchaseNotification forPurchase:purchase];
}

- (void)notifyName:(NSString *)name forPurchase:(Purchase *)purchase {
	
	NSDictionary *dict = nil;
	if (purchase) {
		
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				purchase, ReceiptVerificationPurchaseKey
				, nil];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self
													  userInfo:dict];
}


@end

