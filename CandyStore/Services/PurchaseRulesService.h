//
//  PurchaseRulesService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "Model.h"

extern NSString * const PurchaseRuleDescriptionTooManyCandiesForSmallJar;
NSString * const PurchaseRuleDescriptionPurchaseRulesPurchasesDisabled;

typedef enum {
	
	PurchaseRulesOK,
	PurchaseRulesTooManyCandiesForSmallJar,
	PurchaseRulesAlreadySubscribedToExchange,
	PurchaseRulesAlreadyBoughtBigJar,
	PurchaseRulesPurchasesDisabled
	
} PurchaseRules;

@interface PurchaseRulesService : NSObject

+ (BOOL)shouldEnableBuyButtonForProduct:(Product *)product;
+ (PurchaseRules)canBuyMoreProduct:(Product *)product;

@end

