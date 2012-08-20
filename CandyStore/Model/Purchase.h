//
//  Purchase.h
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Purchase : NSManagedObject {
@private
}
@property (nonatomic, strong) NSData * receipt;
@property (nonatomic, strong) NSString * transactionIdentifier;
@property (nonatomic, strong) NSString * productIdentifier;
@property (nonatomic, strong) NSNumber * isExpiredData;
@property (nonatomic, strong) Product *product;

@end
