//
//  ExchangeItemRepository.m
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeItemRepository.h"
#import "ProductRepository.h"


@implementation ExchangeItemRepository


#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super initWithContext:aManagedObjectContext]) return nil;
	
	[self setTypeName:@"ExchangeItem"];
	
	NSSortDescriptor *kindSort = [NSSortDescriptor sortDescriptorWithKey:@"product.productKindData" ascending:YES];
	NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:@"product.index" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:kindSort, titleSort, nil];
	[self setDefaultSortDescriptors:sortDescriptors];
	
	[self setDefaultSectionNameKeyPath:@"product.productKindData"];
	
	return self;
}


#pragma mark -
#pragma mark ExchangeItemRepository
- (ExchangeItem *)setOrCreateCreditsFromQuantity:(int)quantity {
	
	ExchangeItem *item = [self creditsItem];
	if (!item) {
		
		ProductRepository *repo = [[ProductRepository alloc] initWithContext:self.managedObjectContext];
		NSArray *all = [repo fetchProductsForProductKind:ProductKindExchange];
		[repo release];
		if (all.count == 0) {
			return nil;
		}
		
		Product *product = (Product *)[all lastObject];
		
		item = (ExchangeItem *)[self insertNewObject];
		[item setProduct:product];
		[product setExchangeItem:item];
	}
	
	[item setQuantityAvailable:[NSNumber numberWithInteger:quantity]];
	return item;
}

- (ExchangeItem *)creditsItem {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product.productKindData == %d", ProductKindExchange];
	NSArray *all = [self fetchForSort:self.defaultSortDescriptors andPredicate:pred];
	return [all lastObject];
}

- (NSFetchedResultsController *)controllerForExchangeView {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product.productKindData != %d", ProductKindBigCandyJar];
	return [self controllerWithSort:self.defaultSortDescriptors andPredicate:pred];
}

- (ExchangeItem *)createOrUpdateExchangeItemForProductIdentifier:(NSString *)productIdentifier {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"product.identifier == %@", productIdentifier];
	NSArray *all = [self fetchForSort:self.defaultSortDescriptors andPredicate:pred];
	ExchangeItem *item = (all.count > 0)
	? (ExchangeItem *)[all lastObject]
	: nil;
	
	if (!item) {
		
		item = (ExchangeItem *)[self insertNewObject];
		
		ProductRepository *repo = [[ProductRepository alloc] initWithContext:self.managedObjectContext];
		Product *product = (Product *)[repo itemForId:productIdentifier];
		[item setProduct:product];
		[product setExchangeItem:item];
	}
	
	return item;
}

@end

