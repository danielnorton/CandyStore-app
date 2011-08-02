//
//  TransactionReceiptService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface TransactionReceiptService : NSObject <SKPaymentTransactionObserver>

- (void)beginObserving;
- (void)endObserving;

@end
