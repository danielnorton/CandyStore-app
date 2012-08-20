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
#import "ReceiptVerificationLocalService.h"

NSString * const TransactionReceiptServiceProcessingNotification = @"TransactionReceiptServiceProcessingNotification";
NSString * const TransactionReceiptServiceCompletedNotification = @"TransactionReceiptServiceCompletedNotification";
NSString * const TransactionReceiptServiceFailedNotification = @"TransactionReceiptServiceFailedNotification";
NSString * const TransactionReceiptServiceRestoreCompletedNotification = @"TransactionReceiptServiceRestoreCompletedNotification";
NSString * const TransactionReceiptServiceRestoreFailedNotification = @"TransactionReceiptServiceRestoreFailedNotification";
NSString * const TransactionReceiptServiceKeyTransaction = @"TransactionReceiptServiceKeyTransaction";


@implementation TransactionReceiptService


#pragma mark -
#pragma mark SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *) transactions {
	
	[transactions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		SKPaymentTransaction *transaction = (SKPaymentTransaction *)obj;
		
		[self notifyName:TransactionReceiptServiceProcessingNotification forTransaction:transaction];
				
		BOOL shouldProcess = ((transaction.transactionState == SKPaymentTransactionStatePurchased)
							  || (transaction.transactionState == SKPaymentTransactionStateRestored));
		if (shouldProcess) {
			
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
			
			NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
			ProductRepository *productRepo = [[ProductRepository alloc] initWithContext:context];
			PurchaseRepository *purchaseRepo = [[PurchaseRepository alloc] initWithContext:context];
			
			NSString *productIdentifier = transaction.payment.productIdentifier;
			NSData *receipt = transaction.transactionReceipt;
			
			NSString *transactionIdentifier = transaction.originalTransaction
			? transaction.originalTransaction.transactionIdentifier
			: transaction.transactionIdentifier;
			
			NSLog(@"transaction state: %d,  transactionIdentifier: %@,  productIdentifier: %@", transaction.transactionState, transactionIdentifier, productIdentifier);

			Product *product = (Product *)[productRepo itemForId:productIdentifier];
			Purchase *purchase = [purchaseRepo addOrRetreivePurchaseForProduct:product withTransactionIdentifier:transactionIdentifier];
			[purchase setProductIdentifier:productIdentifier];
			[purchase setReceipt:receipt];
			
			NSError *error = nil;
			if (![productRepo save:&error]) {
				
				[self notifyName:TransactionReceiptServiceFailedNotification forTransaction:transaction];
				return;
			}
			
			
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
			
			[self notifyName:TransactionReceiptServiceCompletedNotification forTransaction:transaction];
			
		} else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
			
			[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
			[self notifyName:TransactionReceiptServiceFailedNotification forTransaction:transaction];
		}
	}];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
	
	[self notifyName:TransactionReceiptServiceRestoreFailedNotification];
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {

	[self notifyName:TransactionReceiptServiceRestoreCompletedNotification];
}


#pragma mark -
#pragma mark TransactionReceiptService
- (void)beginObserving {
	
	[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)endObserving {
	
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)restoreTransactions {
	
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark Private Messages
- (void)notifyName:(NSString *)name forTransaction:(SKPaymentTransaction *)transaction {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	NSDictionary *dict = @{TransactionReceiptServiceKeyTransaction: transaction};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self
													  userInfo:dict];
}

- (void)notifyName:(NSString *)name {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self
													  userInfo:nil];
}


@end

