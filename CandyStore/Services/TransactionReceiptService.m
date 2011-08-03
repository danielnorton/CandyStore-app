//
//  TransactionReceiptService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "TransactionReceiptService.h"
#import "Model.h"
#import "ProductRepository.h"


NSString * const TransactionReceiptServiceNotificationProcessing = @"TransactionReceiptServiceNotificationProcessing";
NSString * const TransactionReceiptServiceNotificationCompleted = @"TransactionReceiptServiceNotificationCompleted";
NSString * const TransactionReceiptServiceNotificationFailed = @"TransactionReceiptServiceNotificationFailed";
NSString * const TransactionReceiptServiceKeyTransaction = @"TransactionReceiptServiceKeyTransaction";


@interface TransactionReceiptService()

- (void)notifyName:(NSString *)name forTransaction:(SKPaymentTransaction *)transaction;

@end

@implementation TransactionReceiptService


#pragma mark -
#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *) transactions {
	
	[transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		SKPaymentTransaction *transaction = (SKPaymentTransaction *)obj;
		
		[self notifyName:TransactionReceiptServiceNotificationProcessing forTransaction:transaction];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(transaction.transactionState == SKPaymentTransactionStatePurchasing)];
		
		if ((transaction.transactionState == SKPaymentTransactionStatePurchased)
			|| (transaction.transactionState == SKPaymentTransactionStateRestored)) {
			
			ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
		
			NSString *identifier = transaction.payment.productIdentifier;
			NSString *transactionIdentifier = transaction.transactionIdentifier;
			NSData *receipt = transaction.transactionReceipt;
			SKPayment *payment = transaction.payment;
			
			Product *product = (Product *)[repo itemForId:identifier];
			if (product) {
				
				Purchase *purchase = [repo addPurchaseToProduct:product];
				[purchase setTransactionIdentifier:transactionIdentifier];
				[purchase setQuantity:[NSNumber numberWithInteger:payment.quantity]];
				[purchase setReceipt:receipt];
			}
			
			NSError *error = nil;
			if (![repo save:&error]) {
				
				// TODO: still thinking of what to do if this fails.
			}
			
			[repo release];
			
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
			
			[self notifyName:TransactionReceiptServiceNotificationCompleted forTransaction:transaction];
			
		} else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
			
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
			[self notifyName:TransactionReceiptServiceNotificationFailed forTransaction:transaction];
		}
	}];
}

#pragma mark -
#pragma mark TransactionReceiptService
- (void)beginObserving {
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)endObserving {
	
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


#pragma mark Private Extension
- (void)notifyName:(NSString *)name forTransaction:(SKPaymentTransaction *)transaction {
	
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  transaction, TransactionReceiptServiceKeyTransaction
						  , nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self
													  userInfo:dict];
}


@end

