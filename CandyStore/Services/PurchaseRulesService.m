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

#define kMaxCandyForSmallJar 4

NSString * const PurchaseRuleDescriptionTooManyCandiesForSmallJar = @"You need to buy the Big Candy Jar in the Candy Store to buy more candy";

@implementation PurchaseRulesService

+ (BOOL)shouldEnableBuyButtonForProduct:(Product *)product {
	
	if (![CandyShopService canMakePayments]) return NO;
	
	if ([product.internalKey isEqualToString:InternalKeyCandy]) return YES;
	
	return ([self canBuyMoreProduct:product] == PurchaseRulesOK);
}

+ (PurchaseRules)canBuyMoreProduct:(Product *)product {
	
	if (![CandyShopService canMakePayments]) return PurchaseRulesPurchasesDisabled;
	
	if ([product.internalKey isEqualToString:InternalKeyCandy]) {
	
		if ([CandyShopService hasBigJar]) return PurchaseRulesOK;
		
		ProductRepository *repo = [[ProductRepository alloc] initWithContext:product.managedObjectContext];
		int count = [repo candyCount];
		[repo release];
		
		if (count >= kMaxCandyForSmallJar) return PurchaseRulesTooManyCandiesForSmallJar;
	}
	
	if ([product.internalKey isEqualToString:InternalKeyBigCandyJar]) {
		
		if (product.purchases.count == 0) {
			
			return PurchaseRulesOK;
			
		} else {
			
			return PurchaseRulesAlreadyBoughtBigJar;
		}
	}
	
	// product is Exchange or subscription to Exchange.
	// if product is the parent Product (i.e. not one
	// of the subscriptions), return NO
	if (!product.parent) return NO;
	
	__block PurchaseRules answer = PurchaseRulesOK;
	[product.parent.subscriptions enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		
		Product *subscription = (Product *)obj;
		if (subscription.purchases.count > 0) {
			answer = PurchaseRulesAlreadySubscribedToExchange;
		}
	}];
	
	return answer;
}

@end
