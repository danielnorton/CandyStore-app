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
#import "PurchaseRepository.h"


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
		
		NSString *identifier = transaction.payment.productIdentifier;
		NSString *transactionIdentifier = transaction.transactionIdentifier;
//		NSData *receipt = transaction.transactionReceipt;
		SKPayment *payment = transaction.payment;
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(transaction.transactionState == SKPaymentTransactionStatePurchasing)];
		
		if ((transaction.transactionState == SKPaymentTransactionStatePurchased)
			|| (transaction.transactionState == SKPaymentTransactionStateRestored)) {
			
			ProductRepository *productRepo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
			PurchaseRepository *purchaseRepo = [[PurchaseRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
		
			Product *product = (Product *)[productRepo itemForId:identifier];
			if (product) {
				
				Purchase *purchase = [purchaseRepo addPurchaseToProduct:product];
				[purchase setTransactionIdentifier:transactionIdentifier];
				[purchase setQuantity:[NSNumber numberWithInteger:payment.quantity]];
			}
			
			NSError *error = nil;
			if (![purchaseRepo save:&error]) {
				
				// TODO: still thinking of what to do if this fails.
			}
			
			[productRepo release];
			[purchaseRepo release];
			
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
			
			[self notifyName:TransactionReceiptServiceNotificationCompleted forTransaction:transaction];
			
		} else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
			
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

