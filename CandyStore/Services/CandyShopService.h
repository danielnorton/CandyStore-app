//
//  CandyShopService.h
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

extern NSString * const InternalKeyCandy;
extern NSString * const InternalKeyBigCandyJar;
extern NSString * const InternalKeyExchange;


@interface CandyShopService : NSObject

+ (BOOL)isStoreKitEnabled;
+ (BOOL)hasBigCandyJar;
+ (BOOL)canSeeExchangeTab;
+ (BOOL)canAddToExchangeCredits;
+ (BOOL)canMakePayments;

@end
