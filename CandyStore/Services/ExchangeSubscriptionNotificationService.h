//
//  ExchangeSubscriptionNotificationService.h
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//


@interface ExchangeSubscriptionNotificationService : NSObject

@property (nonatomic, assign) int counter;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) BOOL shouldNotify;

- (void)reset;

@end
