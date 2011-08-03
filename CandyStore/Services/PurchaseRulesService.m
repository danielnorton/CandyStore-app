//
//  PurchaseRulesService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "PurchaseRulesService.h"
#import "ProductRepository.h"
#import "CandyShopService.h"


@implementation PurchaseRulesService

+ (BOOL)shouldEnableBuyButtonForProduct:(Product *)product {
	
	if ([product.internalKey isEqualToString:InternalKeyCandy]) return YES;
	
	return [self canBuyMoreProduct:product];
}

+ (BOOL)canBuyMoreProduct:(Product *)product {
	
	if ([product.internalKey isEqualToString:InternalKeyCandy]) return YES;
	
	if ([product.internalKey isEqualToString:InternalKeyBigCandyJar]) return (product.purchases.count == 0);
	
	// product is Exchange or subscription to Exchange.
	// if product is the parent Product (i.e. not one
	// of the subscriptions), return NO
	if (!product.parent) return NO;
	
	__block BOOL answer = YES;
	[product.parent.subscriptions enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		
		Product *subscription = (Product *)obj;
		if (subscription.purchases.count > 0) {
			answer = NO;
		}
	}];
	
	return answer;
}

@end
