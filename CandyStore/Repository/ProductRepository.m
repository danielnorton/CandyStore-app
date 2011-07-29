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
	NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObjects:kindSort, titleSort, nil];
	[self setDefaultSortDescriptors:sortDescriptors];

	[self setDefaultSectionNameKeyPath:@"productKindData"];
	[self setKeyName:@"identifier"];
	
	return self;
}

@end
