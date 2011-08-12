//
//  ExchangeListItemCell.m
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeListItemCell.h"

@implementation ExchangeListItemCell

@synthesize titleLabel;
@synthesize quantityLabel;
@synthesize iconView;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[titleLabel release];
	[quantityLabel release];
	[iconView release];
	[super dealloc];
}


#pragma mark -
#pragma mark ExchangeListItemCell
+ (float)defaultHeight {
	return 66.0f;
}


@end
