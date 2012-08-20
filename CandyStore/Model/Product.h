//
//  Product.h
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ExchangeItem, Product, Purchase;

@interface Product : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * identifier;
@property (nonatomic, strong) NSString * imagePath;
@property (nonatomic, strong) NSNumber * index;
@property (nonatomic, strong) NSString * internalKey;
@property (nonatomic, strong) NSNumber * isActiveData;
@property (nonatomic, strong) NSString * localizedPrice;
@property (nonatomic, strong) NSString * productDescription;
@property (nonatomic, strong) NSNumber * productKindData;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) ExchangeItem *exchangeItem;
@property (nonatomic, strong) Product *parent;
@property (nonatomic, strong) NSSet *purchases;
@property (nonatomic, strong) NSSet *subscriptions;
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
