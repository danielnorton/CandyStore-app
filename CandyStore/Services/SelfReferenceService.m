//
//  SelfReferenceService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/19/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//

#import "SelfReferenceService.h"

static NSMutableArray *bucket;

@implementation SelfReferenceService


#pragma mark -
#pragma mark NSObject
+ (void)initialize {
	
	bucket = [[NSMutableArray alloc] initWithCapacity:0];
}

+ (void)add:(id)object {
	
	if (!object) return;
	[bucket addObject:object];
}


+ (void)remove:(id)object {
	
	[bucket removeObject:object];
}


@end
