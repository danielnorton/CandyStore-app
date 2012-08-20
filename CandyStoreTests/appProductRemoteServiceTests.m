//
//  AppProductRemoteServiceTests.m
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "AppProductRemoteServiceTests.h"
#import "NSObject+waitForCompletion.h"


@interface AppProductRemoteServiceTests()

@property (nonatomic, strong) NSArray *products;

@end


@implementation AppProductRemoteServiceTests

@synthesize products;

#pragma mark -
#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	
	[self setProducts:nil];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	
	[self setProducts:nil];
}


#pragma mark AppProductRemoteServiceDelegate
- (void)appProductRemoteService:(AppProductRemoteService *)sender didCompleteRetreiveProducts:(NSArray *)theProducts {
	
	[self setProducts:theProducts];
}

- (void)appProductRemoteServiceDidFailRetreiveProducts:(AppProductRemoteService *)sender {
	
	[self setProducts:nil];
}


#pragma mark -
#pragma mark AppProductRemoteServiceTests
#pragma mark Tests
- (void)setUp {
	
	[self setProducts:nil];
	
	AppProductRemoteService *service = [[AppProductRemoteService alloc] init];
	[service setDelegate:self];
	[service beginRetreiveProducts];
	
	[self waitForCompletion:1.0f doneTest:^BOOL(void) {
		
		return (products != nil);
	}];
}

- (void)testShouldGetProducts {
	
	STAssertNotNil(products, @"Didn't retreive products.");
}


@end
