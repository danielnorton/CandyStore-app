//
//  IAPIdentifiersRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "IAPIdentifiersRemoteService.h"


@interface IAPIdentifiersRemoteService()

- (void)notifyDelegateDidRetreiveIdentifiers:(NSArray *)identifiers;

@end


@implementation IAPIdentifiersRemoteService

@synthesize delegate;


#pragma mark -
#pragma mark IAPIdentifiersRemoteService
#pragma mark Public Messages
- (void)beginRetreiveIdentifiers {

	[self performSelector:@selector(fake) withObject:nil afterDelay:1.0f];
}

- (void)fake {
	
	NSArray *fakes = [NSArray arrayWithObject:@""];
	[self notifyDelegateDidRetreiveIdentifiers:fakes];
}


#pragma mark Private Extension
- (void)notifyDelegateDidRetreiveIdentifiers:(NSArray *)identifiers {

	if (![delegate conformsToProtocol:@protocol(IAPIdentifiersRemoteServiceDelegate)]) return;
	[delegate identifierRemoteService:self didCompleteRetreiveIdentifiers:identifiers];
}


@end

