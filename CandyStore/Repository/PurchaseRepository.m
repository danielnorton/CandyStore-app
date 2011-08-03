//
//  PurchaseRepository.m
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "PurchaseRepository.h"

@implementation PurchaseRepository

#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super initWithContext:aManagedObjectContext]) return nil;
	
	[self setTypeName:@"Purchase"];
	[self setDefaultSortDescriptorsByKey:@"transactionIdentifier"];
	[self setKeyName:@"transactionIdentifier"];
	
	return self;
}

@end
