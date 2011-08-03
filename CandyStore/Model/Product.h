//
//  Product.h
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Product, Purchase;

@interface Product : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSNumber * index;
@property (nonatomic, retain) NSString * internalKey;
@property (nonatomic, retain) NSNumber * isActiveData;
@property (nonatomic, retain) NSString * localizedPrice;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * productDescription;
@property (nonatomic, retain) NSNumber * productKindData;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) Product *parent;
@property (nonatomic, retain) NSSet *purchases;
@property (nonatomic, retain) NSSet *subscriptions;
@end

@interface Product (CoreDataGeneratedAccessors)

- (void)addPurchasesObject:(Purchase *)value;
- (void)removePurchasesObject:(Purchase *)value;
- (void)addPurchases:(NSSet *)values;
- (void)removePurchases:(NSSet *)values;

- (void)addSubscriptionsObject:(Product *)value;
- (void)removeSubscriptionsObject:(Product *)value;
- (void)addSubscriptions:(NSSet *)values;
- (void)removeSubscriptions:(NSSet *)values;

@end
