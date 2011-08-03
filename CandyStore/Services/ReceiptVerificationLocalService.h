//
//  ReceiptVerificationLocalService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ReceiptVerificationRemoteService.h"

extern NSString * const ReceiptVerificationDidVerifyPurchaseNotification;
extern NSString * const ReceiptVerificationWillDeletePurchaseNotification;
extern NSString * const ReceiptVerificationDidDeletePurchaseNotification;
extern NSString * const ReceiptVerificationWillExpireSubscriptionPurchaseNotification;
extern NSString * const ReceiptVerificationDidExpireSubscriptionPurchaseNotification;
extern NSString * const ReceiptVerificationPurchaseKey;


@interface ReceiptVerificationLocalService : NSObject
<ReceiptVerificationRemoteServiceDelegate>


+ (void)verifyAllPurchases;
- (void)verifyPurchase:(Purchase *)purchase;

@end
