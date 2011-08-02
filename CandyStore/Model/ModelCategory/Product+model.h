//
//  Product+model.h
//  CandyStore
//
//  Created by Daniel Norton on 7/28/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "Product.h"


typedef enum {
	
	ProductKindUnknown,
	ProductKindBigCandyJar,
	ProductKindExchange,
	ProductKindCandy
	
} ProductKind;

@interface Product(model)

@property (nonatomic, assign) ProductKind kind;
@property (nonatomic, assign) BOOL isActive;

@end
