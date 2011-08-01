//
//  ShopListItemCell.m
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ShopListItemCell.h"

@implementation ShopListItemCell

@synthesize titleLabel;
@synthesize priceLabel;
@synthesize iconView;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {

	[titleLabel release];
	[priceLabel release];
	[iconView release];
	[super dealloc];
}

@end
