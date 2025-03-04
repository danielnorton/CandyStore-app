//
//  TransactionReceiptService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>

extern NSString * const TransactionReceiptServiceProcessingNotification;
extern NSString * const TransactionReceiptServiceCompletedNotification;
extern NSString * const TransactionReceiptServiceFailedNotification;
extern NSString * const TransactionReceiptServiceRestoreCompletedNotification;
extern NSString * const TransactionReceiptServiceRestoreFailedNotification;
extern NSString * const TransactionReceiptServiceKeyTransaction;

@interface TransactionReceiptService : NSObject <SKPaymentTransactionObserver>

- (void)beginObserving;
- (void)endObserving;
- (void)restoreTransactions;

@end
