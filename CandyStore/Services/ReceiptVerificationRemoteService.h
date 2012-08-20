//
//  ReceiptVerificationRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RemoteServiceBase.h"
#import "Model.h"


// these correspond to Apple's response codes
// See In App Purchasing Programming Guide : Verifying an Auto-renewable Subscription Receipt
typedef NS_ENUM(uint, ReceiptVerificationRemoteServiceCode) {
	
	ReceiptVerificationRemoteServiceCodeFailedInvalidLocalData = -2,
	ReceiptVerificationRemoteServiceCodeFailedNonAutoRenewSubscription = -1,
	ReceiptVerificationRemoteServiceCodeSuccess = 0,
	ReceiptVerificationRemoteServiceCodeFailedParseJson = 21000,
	ReceiptVerificationRemoteServiceCodeMalformedData = 21002,
	ReceiptVerificationRemoteServiceCodeCouldNotBeAuthenticated = 21003,
	ReceiptVerificationRemoteServiceCodeInvalidSharedSecret = 21004,
	ReceiptVerificationRemoteServiceCodeReceiptServerUnavailable = 21005,
	ReceiptVerificationRemoteServiceCodeSubscriptionExpired = 21006,
	
};


@class ReceiptVerificationRemoteService;


@protocol ReceiptVerificationRemoteServiceDelegate <NSObject, RemoteServiceDelegate>

- (void)receiptVerificationRemoteService:(ReceiptVerificationRemoteService *)sender
						  didReceiveCode:(ReceiptVerificationRemoteServiceCode)code
							 forPurchase:(Purchase *)purchase;

- (void)receiptVerificationRemoteService:(ReceiptVerificationRemoteService *)sender
					  didFailForPurchase:(Purchase *)purchase;

@end


@interface ReceiptVerificationRemoteService : RemoteServiceBase

- (void)beginVerifyPurchase:(Purchase *)purchase;

@end
