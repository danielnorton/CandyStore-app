//
//  CandyShopService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "CandyShopService.h"
#import "Model.h"
#import "PurchaseRepository.h"


NSString * const InternalKeyCandy = @"candy";
NSString * const InternalKeyBigCandyJar = @"bigcandyjar";
NSString * const InternalKeyExchange = @"exchange";


@implementation CandyShopService


#pragma mark -
#pragma mark CandyShopService
+ (BOOL)hasBigCandyJar {
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	BOOL answer = [repo hasBigCandyJar];
	[repo release];
	
	return answer;
}

+ (BOOL)hasExchange {
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	BOOL subscribed = [repo hasActiveExchangeSubscription];
	BOOL stuff = [repo hasExchangeCredits];
	[repo release];
	
	return subscribed || stuff;
}

+ (BOOL)canMakePayments {
	return [SKPaymentQueue canMakePayments];
}


@end

