//
//  TransactionReceiptService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "TransactionReceiptService.h"

@implementation TransactionReceiptService


#pragma mark -
#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *) transactions {
	
}

#pragma mark -
#pragma mark TransactionReceiptService
- (void)beginObserving {
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)endObserving {
	
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


@end
