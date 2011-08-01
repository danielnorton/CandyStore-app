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

- (Product *)addSubscriptionToProduct:(Product *)product;
- (void)removeSubscriptionFromProduct:(Product *)subscription;
- (NSFetchedResultsController *)controllerforCandyShop;

@end
