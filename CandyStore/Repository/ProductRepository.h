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
- (void)setAllProductsInactive;
- (NSFetchedResultsController *)controllerForCandyShop;
- (NSFetchedResultsController *)controllerForMyCandyJar;
- (NSArray *)fetchProductsForProductKind:(ProductKind)kind;

@end
