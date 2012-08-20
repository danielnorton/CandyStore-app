//
//  ProductRepository.m
//  CandyStore
//
//  Created by Daniel Norton on 7/27/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ProductRepository.h"
#import "PurchaseRepository.h"


@implementation ProductRepository


#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super initWithContext:aManagedObjectContext]) return nil;
	
	NSSortDescriptor *kindSort = [NSSortDescriptor sortDescriptorWithKey:@"productKindData" ascending:YES];
	NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
	NSArray *sortDescriptors = @[kindSort, titleSort];
	[self setDefaultSortDescriptors:sortDescriptors];

	[self setDefaultSectionNameKeyPath:@"productKindData"];
	[self setKeyName:@"identifier"];
	
	return self;
}


#pragma mark -
#pragma mark ProductRepository
- (Product *)addOrRetreiveProductFromIdentifer:(NSString *)productIdentifier {
	
	Product *product = (Product *)[self itemForId:productIdentifier];
	if (!product) {
		
		product = (Product *)[self insertNewObject];
		[product setIdentifier:productIdentifier];
	}
	
	return product;
}

- (Product *)addSubscriptionToProduct:(Product *)product {
	
	return [self addOrUpdateSubscriptionFromIdentifer:nil toProduct:product];
}

- (Product *)addOrUpdateSubscriptionFromIdentifer:(NSString *)subscriptionIdentifier toProduct:(Product *)product {
	
	Product *subscription = (Product *)[self itemForId:subscriptionIdentifier];
	if (!subscription) {
		
		subscription = (Product *)[self insertNewObject];
		[subscription setIdentifier:subscriptionIdentifier];
	}
	
	if (![product.subscriptions containsObject:subscription]) {
		
		[product addSubscriptionsObject:subscription];
	}
	
	[subscription setParent:product];
	
	return subscription;
}

- (void)setAllProductsInactive {

	NSArray *all = [self fetchAll];
	[all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		Product *product = (Product *)obj;
		[product setIsActive:NO];
	}];
}

- (NSFetchedResultsController *)controllerForCandyShop {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"parent == nil && isActiveData == 1"];
	return [self controllerWithSort:self.defaultSortDescriptors andPredicate:pred];
}

- (NSFetchedResultsController *)controllerForMyCandyJar {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"productKindData == %d && purchases.@count > 0", ProductKindCandy];
	return [self controllerWithSort:self.defaultSortDescriptors andPredicate:pred];
}

- (NSArray *)fetchProductsForProductKind:(ProductKind)kind {

	NSPredicate *pred = [NSPredicate predicateWithFormat:@"productKindData == %d", kind];
	return [self fetchForSort:self.defaultSortDescriptors andPredicate:pred];
}


@end

