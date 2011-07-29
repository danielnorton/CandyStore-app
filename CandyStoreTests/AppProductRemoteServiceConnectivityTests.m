//
//  AppProductRemoteServiceConnectivityTests.m
//  CandyStore
//
//  Created by Daniel Norton on 7/27/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "AppProductRemoteServiceConnectivityTests.h"
#import "NSObject+waitForCompletion.h"
#import "HTTPRequestService.h"


@interface AppProductRemoteServiceConnectivityTests()

@property (nonatomic, retain) NSArray *products;

@end


@implementation AppProductRemoteServiceConnectivityTests

@synthesize products;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[products release];
	[super dealloc];
}


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
#pragma mark AppProductRemoteServiceConnectivityTests
#pragma mark Tests

// THIS TEST CANNOT RUN WITH OTHER ASYNC TESTS :(
//- (void)setUp {
//	
//	[self setProducts:nil];
//	
//	AppProductRemoteService *service = [[AppProductRemoteService alloc] init];
//	[service setDelegate:self];
//	[service beginRetreiveProducts];
//	[service release];
//	
//	[self waitForCompletion:1.0f doneTest:^BOOL(void) {
//		
//		return (products != nil);
//	}];
//}
//
//- (void)testShouldNotGetProducts {
//	
//	STAssertNil(products, @"Shouldn't retreive products.");
//}


@end
