//
//  Product.m
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright (c) 2011 Daniel Norton. All rights reserved.
//

#import "Product.h"
#import "Product.h"


@implementation Product
@dynamic identifier;
@dynamic imagePath;
@dynamic price;
@dynamic localizedPrice;
@dynamic productDescription;
@dynamic productKindData;
@dynamic title;
@dynamic subscriptions;
@dynamic parent;


- (void)addSubscriptionsObject:(Product *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subscriptions"] addObject:value];
    [self didChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeSubscriptionsObject:(Product *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"subscriptions"] removeObject:value];
    [self didChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addSubscriptions:(NSSet *)values {    
    [self willChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"subscriptions"] unionSet:values];
    [self didChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueUnionSetMutation usingObjects:values];
}

- (void)removeSubscriptions:(NSSet *)values {
    [self willChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
    [[self primitiveValueForKey:@"subscriptions"] minusSet:values];
    [self didChangeValueForKey:@"subscriptions" withSetMutation:NSKeyValueMinusSetMutation usingObjects:values];
}

@end
