//
//  PurchaseRepository.h
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RepositoryBase.h"
#import "Model.h"

@interface PurchaseRepository : RepositoryBase

- (BOOL)hasBigCandyJar;
- (BOOL)hasActiveExchangeSubscription;
- (BOOL)hasExchangeCredits;
- (int)candyPurchaseCount;
- (Purchase *)addOrRetreivePurchaseForProduct:(Product *)product withTransactionIdentifier:(NSString *)transactionIdentifier;
- (void)removePurchaseFromProduct:(Purchase *)purchase;
- (NSArray *)fetchOrphanedPurchases;

@end

