//
//  ProductBuilderService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/27/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ProductBuilderService.h"
#import "Model.h"
#import "ProductRepository.h"


@interface ProductBuilderService()

- (void)setContext:(NSManagedObjectContext *)context;

@end

@implementation ProductBuilderService


@synthesize delegate;
@synthesize status;
@synthesize context;

#pragma mark -
#pragma mark SKRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	
	// TODO:
}

- (void)requestDidFinish:(SKRequest *)request {
	
	// TODO:
}


#pragma mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

	// TODO:
}


#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	
	// TODO:
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	
	// TODO:
}


#pragma mark AppProductRemoteServiceDelegate
- (void)appProductRemoteService:(AppProductRemoteService *)sender didCompleteRetreiveProducts:(NSArray *)theProducts {
	
	// TODO:
}

- (void)appProductRemoteServiceDidFailRetreiveProducts:(AppProductRemoteService *)sender {
	
	// TODO:
}


#pragma mark -
#pragma mark ProductBuilderService
- (void)beginBuildingProducts:(NSManagedObjectContext *)context {

	// TODO:
}


#pragma mark Private Extension
- (void)setContext:(NSManagedObjectContext *)aContext {
	
	if ([context isEqual:aContext]) return;
	[aContext retain];
	[context release];
	context = aContext;
}

@end
