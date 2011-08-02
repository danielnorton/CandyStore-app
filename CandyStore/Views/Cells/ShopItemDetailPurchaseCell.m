//
//  ShopItemDetailPurchaseCell.m
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ShopItemDetailPurchaseCell.h"

@interface ShopItemDetailPurchaseCell()

- (void)notifyDelegateDidPresentBuyButton;
- (void)notifyDelegateDidChooseToBuy;

@end

@implementation ShopItemDetailPurchaseCell

@synthesize buyButton;
@synthesize titleLabel;
@synthesize iconView;
@synthesize product;
@synthesize delegate;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {

	[buyButton release];
	[titleLabel release];
	[iconView release];
	[super dealloc];
}


#pragma mark -
#pragma mark StoreItemCell
#pragma mark IBAction
- (IBAction)didTapBuyButton:(id)sender {
	
	if (!buyButton.isSelected) {
		
		[buyButton setSelected:YES];
		[self notifyDelegateDidPresentBuyButton];
		
	} else {
	
		[self notifyDelegateDidChooseToBuy];
	}
}


#pragma mark -
#pragma mark ShopItemDetailPurchaseCell
#pragma mark Private Extension
- (void)notifyDelegateDidPresentBuyButton {
	
	if (![delegate conformsToProtocol:@protocol(ShopItemDetailPurchaseCellDelegate)]) return;
	[delegate shopItemDetailPurchaseCell:self didPresentBuyButtonForProduct:product];
}

- (void)notifyDelegateDidChooseToBuy {
	
	if (![delegate conformsToProtocol:@protocol(ShopItemDetailPurchaseCellDelegate)]) return;
	[delegate shopItemDetailPurchaseCell:self didChooseToBuyProduct:product];
}

@end