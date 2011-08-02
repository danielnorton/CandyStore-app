//
//  CandyShopService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyShopService.h"
#import "Model.h"
#import "ProductRepository.h"

#define kInternalKeyCandy @"candy"
#define kInternalKeyBigCandyJar @"bigcandyjar"
#define kInternalKeyExchange @"exchange"


@interface CandyShopService()

+ (BOOL)hasPurchasedInternalKey:(NSString *)internalKey;

@end

@implementation CandyShopService


#pragma mark -
#pragma mark CandyShopService
+ (BOOL)hasBigJar {
	
	return [self hasPurchasedInternalKey:kInternalKeyBigCandyJar];
}

+ (BOOL)hasExchange {
	
	return [self hasPurchasedInternalKey:kInternalKeyExchange];
}


#pragma mark -
#pragma mark CandyShopService
+ (BOOL)hasPurchasedInternalKey:(NSString *)internalKey {
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"internalKey == %@ && purchases.@count > 1", internalKey];
	NSFetchRequest *request = [repo newFetchRequestWithSort:repo.defaultSortDescriptors andPredicate:pred];
	int count = [repo.managedObjectContext countForFetchRequest:request error:nil];
	
	return count == 1;
}


@end

