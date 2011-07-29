//
//  Product.h
//  CandyStore
//
//  Created by Daniel Norton on 7/28/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Product : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * imagePath;
@property (nonatomic, retain) NSDecimalNumber * price;
@property (nonatomic, retain) NSString * priceLocaleIdentifier;
@property (nonatomic, retain) NSString * productDescription;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subTitle;
@property (nonatomic, retain) NSNumber * productKindData;

@end
