//
//  JarListItemCell.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "JarListItemCell.h"
#import "Style.h"

@implementation JarListItemCell


#pragma mark -
#pragma mark JarListItemCell
- (void)configureButtonDefaults {
	
	[_exchangeButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
	[_exchangeButton setTitleColor:[UIColor buyButtonTextColor] forState:UIControlStateNormal];
	[_exchangeButton setTitleShadowColor:[UIColor buyButtonShadowColor] forState:UIControlStateNormal];
	
	[_exchangeButton setTitleColor:[UIColor buyButtonDisabledTextColor] forState:UIControlStateDisabled];
	[_exchangeButton setTitleShadowColor:[UIColor buyButtonDisabledShadowColor] forState:UIControlStateDisabled];
	
	[_eatButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
	[_eatButton setTitleColor:[UIColor buyButtonTextColor] forState:UIControlStateNormal];
	[_eatButton setTitleShadowColor:[UIColor buyButtonShadowColor] forState:UIControlStateNormal];
	
	[_eatButton setTitleColor:[UIColor buyButtonDisabledTextColor] forState:UIControlStateDisabled];
	[_eatButton setTitleShadowColor:[UIColor buyButtonDisabledShadowColor] forState:UIControlStateDisabled];
	
	UIImage *blue = [[UIImage imageNamed:@"blueBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
	UIImage *green = [[UIImage imageNamed:@"greenBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
	UIImage *gray = [[UIImage imageNamed:@"grayBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
	
	[_exchangeButton setBackgroundColor:[UIColor clearColor]];
	[_exchangeButton setBackgroundImage:blue forState:UIControlStateNormal];
	[_exchangeButton setBackgroundImage:green forState:UIControlStateSelected];
	[_exchangeButton setBackgroundImage:gray forState:UIControlStateDisabled];
	
	[_eatButton setBackgroundColor:[UIColor clearColor]];
	[_eatButton setBackgroundImage:blue forState:UIControlStateNormal];
	[_eatButton setBackgroundImage:green forState:UIControlStateSelected];
	[_eatButton setBackgroundImage:gray forState:UIControlStateDisabled];
}


#pragma mark IBAction
- (IBAction)didTapEatButton:(id)sender {
	
	[self notifyDelegateDidEat];
}

- (IBAction)didTapExchangeButton:(id)sender {
	
	[self notifyDelegateDidExchange];
}


#pragma mark Private Messages
- (void)notifyDelegateDidEat {
	
	if (![_delegate conformsToProtocol:@protocol(JarListItemCellDelegate)]) return;
	[_delegate jarListItemCell:self didEatOneProduct:_product];
}

- (void)notifyDelegateDidExchange {
	
	if (![_delegate conformsToProtocol:@protocol(JarListItemCellDelegate)]) return;
	[_delegate jarListItemCell:self didExchangeOneProduct:_product];
}

@end
