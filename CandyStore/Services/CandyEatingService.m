//
//  CandyEatingService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyEatingService.h"
#import "ProductRepository.h"
#import "CandyShopService.h"


@implementation CandyEatingService


#pragma mark -
#pragma mark CandyEatingService
- (void)eatCandy:(Product *)candy {
	
	if (![candy.internalKey isEqualToString:InternalKeyCandy]) return;
	
	Purchase *purchase = [candy.purchases anyObject];
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:candy.managedObjectContext];
	[repo removePurchaseFromProduct:purchase];
	
	NSError *error = nil;
	[repo save:&error];
}


@end

