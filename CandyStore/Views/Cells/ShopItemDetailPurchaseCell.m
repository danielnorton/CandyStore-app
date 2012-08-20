//
//  ShopItemDetailPurchaseCell.m
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ShopItemDetailPurchaseCell.h"


@implementation ShopItemDetailPurchaseCell


#pragma mark -
#pragma mark StoreItemCell
#pragma mark IBAction
- (IBAction)didTapBuyButton:(id)sender {
	
	if (!_buyButton.isSelected) {
		
		[_buyButton setSelected:YES];
		[self notifyDelegateDidPresentBuyButton];
		
	} else {
	
		[self notifyDelegateDidChooseToBuy];
	}
	
	[self resizeTitleFromBuyButton];
}


#pragma mark -
#pragma mark ShopItemDetailPurchaseCell
- (void)resizeTitleFromBuyButton {
	
	CGRect t = _titleLabel.frame;
	CGRect b = _buyButton.frame;
	float w = b.origin.x - t.origin.x - 10.0f;
	CGRect newT = CGRectMake(t.origin.x, t.origin.y, w, t.size.height);
	[_titleLabel setFrame:newT];
}


#pragma mark Private Messages
- (void)notifyDelegateDidPresentBuyButton {
	
	if (![_delegate conformsToProtocol:@protocol(ShopItemDetailPurchaseCellDelegate)]) return;
	[_delegate shopItemDetailPurchaseCell:self didPresentBuyButtonForProduct:_product];
}

- (void)notifyDelegateDidChooseToBuy {
	
	if (![_delegate conformsToProtocol:@protocol(ShopItemDetailPurchaseCellDelegate)]) return;
	[_delegate shopItemDetailPurchaseCell:self didChooseToBuyProduct:_product];
}

@end
