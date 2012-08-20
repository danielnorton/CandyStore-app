//
//  JarListItemCell.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "JarListItemCell.h"


@implementation JarListItemCell


#pragma mark -
#pragma mark JarListItemCell
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
	[_delegate jarListItemCell:self didEatOneProduct:self.product];
}

- (void)notifyDelegateDidExchange {
	
	if (![_delegate conformsToProtocol:@protocol(JarListItemCellDelegate)]) return;
	[_delegate jarListItemCell:self didExchangeOneProduct:self.product];
}

@end
