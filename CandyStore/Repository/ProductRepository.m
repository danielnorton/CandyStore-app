//
//  ProductRepository.m
//  CandyStore
//
//  Created by Daniel Norton on 7/27/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ProductRepository.h"

@implementation ProductRepository


#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super initWithContext:aManagedObjectContext]) return nil;
	
	[self setTypeName:@"Product"];
	
	NSSortDescriptor *kindSort = [NSSortDescriptor sortDescriptorWithKey:@"productKindData" ascending:YES];
	NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:kindSort, titleSort, nil];
	[self setDefaultSortDescriptors:sortDescriptors];

	[self setDefaultSectionNameKeyPath:@"productKindData"];
	[self setKeyName:@"identifier"];
	
	return self;
}


#pragma mark -
#pragma mark ProductRepository
- (Product *)addSubscriptionToProduct:(Product *)product {
	
	Product *newSubscription = (Product *)[self insertNewObject];
	[product addSubscriptionsObject:newSubscription];
	[newSubscription setParent:product];
	
	return newSubscription;
}

- (void)removeSubscriptionFromProduct:(Product *)subscription; {
	
	Product *product = subscription.parent;
	if (!product) return;
	
	[product removeSubscriptionsObject:subscription];
	[subscription setParent:nil];
	[self.managedObjectContext deleteObject:subscription];
}

- (NSFetchedResultsController *)controllerForCandyShop {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"parent == nil"];
	return [self controllerWithSort:self.defaultSortDescriptors andPredicate:pred];
}


@end

