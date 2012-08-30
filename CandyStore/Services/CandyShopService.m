//
//  CandyShopService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <TargetConditionals.h>
#import <StoreKit/StoreKit.h>
#import "CandyShopService.h"
#import "Model.h"
#import "PurchaseRepository.h"
#import "ExchangeItemRepository.h"

#define kKeyUseStoreKit @"KeyUseStoreKit"


NSString * const InternalKeyCandy = @"candy";
NSString * const InternalKeyBigCandyJar = @"bigcandyjar";
NSString * const InternalKeyExchange = @"exchange";


static BOOL isEnabled = YES;


@implementation CandyShopService


#pragma mark -
#pragma mark NSObject
+ (void)initialize {
	
#if TARGET_IPHONE_SIMULATOR
	
	isEnabled = NO;
	
#endif

}


#pragma mark -
#pragma mark CandyShopService
+ (BOOL)isStoreKitEnabled {
	
	return isEnabled;
}

+ (BOOL)hasBigCandyJar {
	
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	return [repo hasBigCandyJar];
}

+ (BOOL)canSeeExchangeTab {
	
	if ([self canAddToExchangeCredits]) return YES;
	
	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	ExchangeItemRepository *exchangeRepo = [[ExchangeItemRepository alloc] initWithContext:context];
	ExchangeItem *credits = [exchangeRepo creditsItem];
	return [credits.quantityAvailable integerValue] > 0;
}

+ (BOOL)canAddToExchangeCredits {

	NSManagedObjectContext *context = [ModelCore sharedManager].managedObjectContext;
	PurchaseRepository *purchaseRepo = [[PurchaseRepository alloc] initWithContext:context];
	return [purchaseRepo hasActiveExchangeSubscription];
}

+ (BOOL)canMakePayments {
	
	if (![self isStoreKitEnabled]) return YES;
	
	return [SKPaymentQueue canMakePayments];
}


@end

