//
//  PurchaseRulesService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "PurchaseRulesService.h"
#import "ProductRepository.h"
#import "PurchaseRepository.h"
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
	
	PurchaseRepository *repo = [[[PurchaseRepository alloc] initWithContext:product.managedObjectContext] autorelease];
	
	// Candy. If user has the Big Candy Jar, they can keep buying candy.
	// Otherwise, they are limited to the number of candies they can buy.
	if ([product.internalKey isEqualToString:InternalKeyCandy]) {
	
		if ([CandyShopService hasBigCandyJar]) return PurchaseRulesOK;
		
		int count = [repo candyPurchaseCount];
		return (count >= kMaxCandyForSmallJar)
		? PurchaseRulesTooManyCandiesForSmallJar
		: PurchaseRulesOK;
	}
	
	
	// Candy Jar
	if ([product.internalKey isEqualToString:InternalKeyBigCandyJar]) {
		
		return [repo hasBigCandyJar]
		? PurchaseRulesAlreadyBoughtBigJar
		: PurchaseRulesOK;
	}
	
	
	// Exchange or subscription to Exchange.
	return [repo hasActiveExchangeSubscription]
	? PurchaseRulesAlreadySubscribedToExchange
	: PurchaseRulesOK;
}

@end
