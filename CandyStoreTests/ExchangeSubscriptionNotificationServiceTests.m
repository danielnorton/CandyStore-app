//
//  ExchangeSubscriptionNotificationService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ExchangeSubscriptionNotificationServiceTests.h"
#import	"ExchangeSubscriptionNotificationService.h"


@implementation ExchangeSubscriptionNotificationServiceTests

- (void)testShouldNotAlertUserPurchaseExchange {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	
	[service reset];
	BOOL shouldNotify = service.shouldNotify;
	
	STAssertTrue(shouldNotify, @"should notify.");
}

- (void)testShouldNotAlertUserPurchaseExchange_IncrementTwo {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	
	[service reset];
	service.counter++;
	BOOL shouldNotify = service.shouldNotify;
	
	STAssertTrue(shouldNotify, @"should notify.");
}

- (void)testShouldNotAlertUserPurchaseExchange_IncrementThree {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	
	[service reset];
	service.counter++;
	service.counter++;
	BOOL shouldNotify = service.shouldNotify;
	
	STAssertFalse(shouldNotify, @"should not notify.");
}

- (void)testShouldShowNewUserMessage {
	
	ExchangeSubscriptionNotificationService *service = [[ExchangeSubscriptionNotificationService alloc] init];
	
	[service reset];
	NSString *message = service.message;
	
	STAssertEqualObjects(message, @"Visit the Candy Shop to subscribe to the Candy Exchange service and swap candy", nil);
}

@end

