//
//  JarListItemCell.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "JarListItemCell.h"


@interface JarListItemCell()

- (void)notifyDelegateDidEat;
- (void)notifyDelegateDidExchange;

@end


@implementation JarListItemCell

@synthesize titleLabel;
@synthesize quantityLabel;
@synthesize iconView;
@synthesize eatButton;
@synthesize exchangeButton;
@synthesize product;
@synthesize delegate;


#pragma mark -
#pragma mark JarListItemCell
#pragma mark IBAction
- (IBAction)didTapEatButton:(id)sender {
	
	[self notifyDelegateDidEat];
}

- (IBAction)didTapExchangeButton:(id)sender {
	
	[self notifyDelegateDidExchange];
}


#pragma mark Private Extension
- (void)notifyDelegateDidEat {
	
	if (![delegate conformsToProtocol:@protocol(JarListItemCellDelegate)]) return;
	[delegate jarListItemCell:self didEatOneProduct:self.product];
}

- (void)notifyDelegateDidExchange {
	
	if (![delegate conformsToProtocol:@protocol(JarListItemCellDelegate)]) return;
	[delegate jarListItemCell:self didExchangeOneProduct:self.product];
}

@end
