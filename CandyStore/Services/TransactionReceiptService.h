//
//  TransactionReceiptService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>

extern NSString * const TransactionReceiptServiceNotificationProcessing;
extern NSString * const TransactionReceiptServiceNotificationCompleted;
extern NSString * const TransactionReceiptServiceNotificationFailed;
extern NSString * const TransactionReceiptServiceKeyTransaction;


@interface TransactionReceiptService : NSObject <SKPaymentTransactionObserver>

- (void)beginObserving;
- (void)endObserving;

@end
