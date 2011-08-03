//
//  PurchaseRulesService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "Model.h"


@interface PurchaseRulesService : NSObject

+ (BOOL)shouldEnableBuyButtonForProduct:(Product *)product;
+ (BOOL)canBuyMoreProduct:(Product *)product;

@end

