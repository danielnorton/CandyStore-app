//
//  RemoteServiceBase.m
//
//  Created by Daniel Norton on 3/3/11.
//

#import "RemoteServiceBase.h"
#import "SelfReferenceService.h"


@implementation RemoteServiceBase


#pragma mark -
#pragma mark NSObject
- (id)init {
	
	if (![super init]) return nil;
	
	_expectedReplyCode = 200;
	_method = HTTPRequestServiceMethodPost;
	_returnType = HTTPRequestServiceReturnTypeJson;
	
	return self;
}


#pragma mark HTTPRequestServiceDelegate
- (void)httpRequestServiceDidFinish:(HTTPRequestService *)sender {
	
	[self setReplyCode:sender.httpCode];
	
	if (sender.didFail) {
		
		[self setReplyText:@"An error occurred while parsing the server response"];
		[self notifyDelegateOfFailure:sender];
		
	} else if (_replyCode != _expectedReplyCode) {
			
		[self notifyDelegateOfFailure:sender];
		
	} else {
		
		[self buildModelFromSuccess:sender];
	}
	
	[sender setDelegate:nil];
	[SelfReferenceService remove:self];
}

- (void)httpRequestServiceDidTimeout:(HTTPRequestService *)sender {
	
	[self notifyDelegateOfTimeout];
	
	[sender setDelegate:nil];
	[SelfReferenceService remove:self];
}

- (BOOL)httpRequestServiceShouldContinueAfterHttpCode:(HTTPRequestService *)sender {
	
	[self notifyDelegateOfFailedAuthentication];
	
	[sender setDelegate:nil];
	[SelfReferenceService remove:self];
	
	return NO;
}


#pragma mark -
#pragma mark RemoteServiceBase
- (void)beginRemoteCallWithPath:(NSString *)path withParams:(NSDictionary *)params withUserData:(id)userData {
	
	[SelfReferenceService add:self];
	
	HTTPRequestService *service = [[HTTPRequestService alloc] init];
	[service setDelegate:self];
	[service setUserData:userData];
	
	[service beginRequest:path method:_method params:params withReturnType:_returnType];
}

- (void)buildModelFromSuccess:(HTTPRequestService *)sender {
	// must be implemented by inheritor
}

- (void)notifyDelegateOfFailedAuthentication {
	
	if (![_delegate conformsToProtocol:@protocol(RemoteServiceDelegate)]) return;
	[_delegate remoteServiceDidFailAuthentication:self];
}

- (void)notifyDelegateOfTimeout {
	
	if (![_delegate conformsToProtocol:@protocol(RemoteServiceDelegate)]) return;
	[_delegate remoteServiceDidTimeout:self];
}

- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender {
	// must be implemented by inheritor
}


@end

