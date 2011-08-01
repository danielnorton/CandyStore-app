//
//  ShopItemCell.m
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ShopItemCell.h"

@implementation ShopItemCell

@synthesize buyButton;
@synthesize titleLabel;
@synthesize subTitleLabel;
@synthesize iconView;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {

	[buyButton release];
	[titleLabel release];
	[subTitleLabel release];
	[iconView release];
	[super dealloc];
}


#pragma mark -
#pragma mark StoreItemCell
#pragma mark IBAction
- (IBAction)didTapBuyButton:(id)sender {
	
	[buyButton setSelected:!buyButton.selected];
}


@end
