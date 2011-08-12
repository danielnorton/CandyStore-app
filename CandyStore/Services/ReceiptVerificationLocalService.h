//
//  ReceiptVerificationLocalService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ReceiptVerificationRemoteService.h"


@class ReceiptVerificationLocalService;

@protocol ReceiptVerificationLocalServiceDelegate <NSObject>

- (void)receiptVerificationLocalServiceDidDeletePurchase:(ReceiptVerificationLocalService *)sender;
- (void)receiptVerificationLocalServiceDidComplete:(ReceiptVerificationLocalService *)sender;

@end


@interface ReceiptVerificationLocalService : NSObject
<ReceiptVerificationRemoteServiceDelegate>

@property (nonatomic, assign) id<ReceiptVerificationLocalServiceDelegate> delegate;

- (void)verifyAllPurchases;

@end
