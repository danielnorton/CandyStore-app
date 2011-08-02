//
//  Product.h
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product;

@interface Product : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * localizedPrice;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * productDescription;
@property (nonatomic, retain) NSNumber * productKindData;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Product *parent;
@property (nonatomic, retain) NSSet *subscriptions;
@property (nonatomic, retain) NSSet *purchases;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addSubscriptionsObject:(Product *)value;
- (void)removeSubscriptionsObject:(Product *)value;
- (void)addSubscriptions:(NSSet *)values;
- (void)removeSubscriptions:(NSSet *)values;

- (void)addPurchasesObject:(NSManagedObject *)value;
- (void)removePurchasesObject:(NSManagedObject *)value;
- (void)addPurchases:(NSSet *)values;
- (void)removePurchases:(NSSet *)values;

@end
