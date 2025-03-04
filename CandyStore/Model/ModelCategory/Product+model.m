//
//  Product+model.m
//  CandyStore
//
//  Created by Daniel Norton on 7/28/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "Product+model.h"

@implementation Product(model)

- (void)setKind:(ProductKind)aKind {
	[self setProductKindData:@(aKind)];
}

- (ProductKind)kind {
	return [self.productKindData integerValue];
}

- (void)setIsActive:(BOOL)active {
	[self setIsActiveData:@(active)];
}

- (BOOL)isActive {
	return [self.isActiveData boolValue];
}


@end
