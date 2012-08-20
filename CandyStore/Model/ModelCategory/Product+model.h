//
//  Product+model.h
//  CandyStore
//
//  Created by Daniel Norton on 7/28/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "Product.h"


typedef NS_ENUM(uint, ProductKind) {
	
	ProductKindUnknown,
	ProductKindBigCandyJar,
	ProductKindExchange,
	ProductKindCandy
	
};

@interface Product(model)

@property (nonatomic, assign) ProductKind kind;
@property (nonatomic, assign) BOOL isActive;

@end
