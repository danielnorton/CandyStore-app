//
//  PurchaseRepository.m
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "PurchaseRepository.h"
#import "CandyShopService.h"


@interface PurchaseRepository()

- (BOOL)simplePredicateCountTest:(NSPredicate *)pred;

@end


@implementation PurchaseRepository

#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super initWithContext:aManagedObjectContext]) return nil;
	
	[self setDefaultSortDescriptorsByKey:@"transactionIdentifier"];
	[self setKeyName:@"transactionIdentifier"];
	
	return self;
}


#pragma mark -
#pragma mark PurchaseRepository
- (BOOL)hasBigCandyJar {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product.internalKey == %@", InternalKeyBigCandyJar];
	return [self simplePredicateCountTest:pred];
}

- (BOOL)hasActiveExchangeSubscription {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"(product.parent.internalKey == %@) && (isExpiredData == 0)", InternalKeyExchange];
	return [self simplePredicateCountTest:pred];
}

- (int)candyPurchaseCount {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product.productKindData == %d", ProductKindCandy];
	NSFetchRequest *request = [self newFetchRequestWithSort:self.defaultSortDescriptors andPredicate:pred];
	int count = [self.managedObjectContext countForFetchRequest:request error:nil];
	[request release];
	
	return count;
}

- (Purchase *)addOrRetreivePurchaseForProduct:(Product *)product withTransactionIdentifier:(NSString *)transactionIdentifier {
	
	Purchase *purchase = (Purchase *)[self itemForId:transactionIdentifier];
	if (!purchase) {
		
		purchase = (Purchase *)[self insertNewObject];
		[purchase setTransactionIdentifier:transactionIdentifier];
	}
	
	if (![product.purchases containsObject:purchase]) {
		
		[product addPurchasesObject:purchase];
	}
	
	[purchase setProduct:product];
	
	return purchase;
}

- (void)removePurchaseFromProduct:(Purchase *)purchase {
	
	Product *product = purchase.product;
	if (!product) return;
	
	[product removePurchasesObject:purchase];
	[purchase setProduct:nil];
	[self.managedObjectContext deleteObject:purchase];
}

- (NSArray *)fetchOrphanedPurchases {

	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product == nil"];
	return [self fetchForSort:self.defaultSortDescriptors andPredicate:pred];
}

- (Purchase *)exchangePurchase {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product.productKindData == %d", ProductKindExchange];
	NSArray *all = [self fetchForSort:self.defaultSortDescriptors andPredicate:pred];
	return (Purchase *)[all lastObject];
}


#pragma mark Private Extension
- (BOOL)simplePredicateCountTest:(NSPredicate *)pred {
	
	NSFetchRequest *request = [self newFetchRequestWithSort:self.defaultSortDescriptors andPredicate:pred];
	int count = [self.managedObjectContext countForFetchRequest:request error:nil];
	[request release];
	
	BOOL answer = (count > 0);
	return answer;
}


@end


