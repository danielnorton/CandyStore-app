//
//  AppProductRemoteService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "AppProductRemoteService.h"
#import "EndpointService.h"


@implementation AppProductRemoteService


#pragma mark -
#pragma mark RemoteServiceBase
- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
	
	[self notifyDelegateDidCompleteRetreiveProducts:sender.json];
}

- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender {

	[self notifyDelegateDidFailRetreiveProducts];
}


#pragma mark -
#pragma mark AppProductRemoteService
#pragma mark Public Messages
- (void)beginRetreiveProducts {

	NSString *path = [EndpointService appProductsPath];
	NSDictionary *params = @{};
	id userData = nil;
	
	[self setMethod:HTTPRequestServiceMethodGet];
	[self setReturnType:HTTPRequestServiceReturnTypeJson];
	[self beginRemoteCallWithPath:path withParams:params withUserData:userData];
}


#pragma mark Private Messages
- (void)notifyDelegateDidCompleteRetreiveProducts:(NSArray *)products {

	id<AppProductRemoteServiceDelegate> del = (id<AppProductRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(AppProductRemoteServiceDelegate)]) return;
	[del appProductRemoteService:self didCompleteRetreiveProducts:products];
}

- (void)notifyDelegateDidFailRetreiveProducts {
	
	id<AppProductRemoteServiceDelegate> del = (id<AppProductRemoteServiceDelegate>)self.delegate;
	if (![del conformsToProtocol:@protocol(AppProductRemoteServiceDelegate)]) return;
	[del appProductRemoteServiceDidFailRetreiveProducts:self];
}

@end

