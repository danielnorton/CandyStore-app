//
//  PurchaseRepository.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "PurchaseRepository.h"

@implementation PurchaseRepository

#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super initWithContext:aManagedObjectContext]) return nil;
	
	[self setTypeName:@"Purchase"];
	[self setDefaultSortDescriptorsByKey:@"product.index"];
	[self setDefaultSectionNameKeyPath:nil];
	[self setKeyName:@"identifier"];
	
	return self;
}


#pragma mark -
#pragma mark PurchaseRepository
- (Purchase *)addPurchaseToProduct:(Product *)product {
	
	Purchase *newPurchase = (Purchase *)[self insertNewObject];
	[product addPurchasesObject:newPurchase];
	[newPurchase setProduct:product];
	
	return newPurchase;
}

- (void)removePurchasenFromProduct:(Purchase *)purchase {
	
	Product *product = purchase.product;
	if (!product) return;
	
	[product removePurchasesObject:purchase];
	[purchase setProduct:nil];
	[self.managedObjectContext deleteObject:purchase];
}

- (NSFetchedResultsController *)controllerForMyCandyJar {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product.productKindData == %d", ProductKindCandy];
	return [self controllerWithSort:self.defaultSortDescriptors andPredicate:pred];
}

@end
