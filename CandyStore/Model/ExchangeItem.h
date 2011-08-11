//
//  ExchangeItem.h
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface ExchangeItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * quantityAvailable;
@property (nonatomic, retain) Product *product;

@end
