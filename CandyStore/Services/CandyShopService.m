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
#import "ExchangeItemRepository.h"


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
	
	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	PurchaseRepository *purchaseRepo = [[PurchaseRepository alloc] initWithContext:context];
	BOOL isSubscribed = [purchaseRepo hasActiveExchangeSubscription];
	[purchaseRepo release];
	
	ExchangeItemRepository *exchangeRepo = [[ExchangeItemRepository alloc] initWithContext:context];
	ExchangeItem *credits = [exchangeRepo creditsItem];
	[exchangeRepo release];
	BOOL hasCredits = credits.quantityAvailable > 0;
	
	return isSubscribed || hasCredits;
}

+ (BOOL)canMakePayments {
	return [SKPaymentQueue canMakePayments];
}


@end

