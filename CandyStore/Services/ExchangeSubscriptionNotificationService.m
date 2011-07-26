//
//  ExchangeSubscriptionNotificationService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ExchangeSubscriptionNotificationService.h"

#define kExchangeNotifyCounterKey @"ExchangeNotifyCounterKey"
#define kExchangeNotifyMaxCounter 2

@implementation ExchangeSubscriptionNotificationService



#pragma mark -
#pragma mark ExchangePurchaseNotificationService
#pragma mark Properties
- (void)setCounter:(int)aCounter {
	
	int marker = aCounter > 0
	? aCounter
	: 0;
	
	NSNumber *state = [NSNumber numberWithInteger:marker];
	[[NSUserDefaults standardUserDefaults] setObject:state forKey:kExchangeNotifyCounterKey];
}

- (int)counter {
	
	NSNumber *state = [[NSUserDefaults standardUserDefaults] objectForKey:kExchangeNotifyCounterKey];
	if (!state) return 0;
	
	return [state integerValue];
}

- (BOOL)shouldNotify {
	
	return self.counter < kExchangeNotifyMaxCounter;
}

- (NSString *)message {
	
	// TODO: possibly change the message if a user has
	// previously subscribed but let their subscription lapse
	return NSLocalizedString(@"Visit the Candy Shop to subscribe to the Candy Exchange service and swap candy", nil);
}


#pragma mark Messages
- (void)reset {
	
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:kExchangeNotifyCounterKey];
}

@end
