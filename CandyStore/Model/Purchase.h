//
//  Purchase.h
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Purchase : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * transactionIdentifier;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) Product *product;

@end
