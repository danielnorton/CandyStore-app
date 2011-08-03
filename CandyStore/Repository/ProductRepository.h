//
//  ProductRepository.h
//  CandyStore
//
//  Created by Daniel Norton on 7/27/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RepositoryBase.h"
#import "Model.h"


@interface ProductRepository : RepositoryBase

- (Product *)addOrRetreiveProductFromIdentifer:(NSString *)productIdentifier;
- (Product *)addSubscriptionToProduct:(Product *)product;
- (Product *)addOrUpdateSubscriptionFromIdentifer:(NSString *)subscriptionIdentifier toProduct:(Product *)product;
- (void)removeSubscriptionFromProduct:(Product *)subscription;
- (NSFetchedResultsController *)controllerForCandyShop;
- (void)setAllProductsInactive;

- (Purchase *)addPurchaseToProduct:(Product *)product;
- (void)removePurchaseFromProduct:(Purchase *)purchase;
- (NSFetchedResultsController *)controllerForMyCandyJar;

- (int)candyCount;

@end
