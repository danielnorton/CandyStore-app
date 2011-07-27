//
//  IAPIdentifiersRemoteServiceTests.m
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "IAPIdentifiersRemoteServiceTests.h"
#import "NSObject+waitForCompletion.h"


@interface IAPIdentifiersRemoteServiceTests()

@property (nonatomic, retain) NSArray *identifiers;

@end


@implementation IAPIdentifiersRemoteServiceTests


@synthesize identifiers;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[identifiers release];
	[super dealloc];
}


#pragma mark IAPIdentifiersRemoteServiceDelegate
- (void)identifierRemoteService:(IAPIdentifiersRemoteService *)sender didCompleteRetreiveIdentifiers:(NSArray *)theIdentifiers {
	
	[self setIdentifiers:theIdentifiers];
}


#pragma mark -
#pragma mark IAPIdentifiersRemoteServiceTests
#pragma mark Tests
- (void)testGetIdentifiers {
	
	[self setIdentifiers:nil];
	
	IAPIdentifiersRemoteService *service = [[IAPIdentifiersRemoteService alloc] init];
	[service setDelegate:self];
	[service beginRetreiveIdentifiers];
	[service release];

	[self waitForCompletion:3.0f doneTest:^BOOL(void) {
		
		return (identifiers != nil);
	}];
	
	STAssertNotNil(identifiers, @"Didn't retreive identifiers.");
}

@end
