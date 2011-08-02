//
//  PurchaseRepository.h
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RepositoryBase.h"
#import "Model.h"


@interface PurchaseRepository : RepositoryBase

- (Purchase *)addPurchaseToProduct:(Product *)product;
- (void)removePurchasenFromProduct:(Purchase *)purchase;
- (NSFetchedResultsController *)controllerForMyCandyJar;

@end
