//
//  CandyShopServiceTests.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyShopServiceTests.h"
#import	"CandyShopService.h"

@implementation CandyShopServiceTests

- (void)testShouldNotYetHaveCandy {
	
	BOOL hasCandy = [CandyShopService hasCandy];
	STAssertFalse(hasCandy, @"shop should not (yet) have candy.");
}

- (void)testShouldNotYetHaveBigJar {
	
	BOOL hasBigJar = [CandyShopService hasBigJar];
	STAssertFalse(hasBigJar, @"shop should not (yet) have big jar.");
}

- (void)testShouldNotYetHaveExchange {
	
	BOOL hasExchange = [CandyShopService hasExchange];
	STAssertFalse(hasExchange, @"shop should not (yet) have exchange.");
}


@end
