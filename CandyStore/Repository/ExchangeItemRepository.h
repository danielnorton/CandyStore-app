//
//  ExchangeItemRepository.h
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RepositoryBase.h"
#import "Model.h"

@interface ExchangeItemRepository : RepositoryBase

- (ExchangeItem *)setOrCreateCreditsFromQuantity:(int)quantity;
- (ExchangeItem *)creditsItem;


@end

