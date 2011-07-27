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
	[self setDefaultSortDescriptorsByKey:@"title"];
	[self setKeyName:@"identifier"];
	
	return self;
}

@end
