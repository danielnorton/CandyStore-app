//
//  HTTPRequestService.m
// 
//
//  Created by Daniel Norton on 11/19/10.
//  Copyright 2010 Bandit Software. All rights reserved.
//

#import "HTTPRequestService.h"
#import "JSON.h"
#import "NSDictionary+join.h"
#import "CandyStoreAppDelegate.h"
#import "UIApplication+delegate.h"
#import "HTTPMultipartBuilder.h"
#import "NSURLRequest+cert.h"


#define kRequestTimeout 15.0f


@interface HTTPRequestService()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;

- (void)setJson:(NSArray *)value;
- (void)setLastError:(NSError *)value;
- (NSMutableURLRequest *)newRequestForPOST:(NSString *)relativeAPIPath params:(NSDictionary *)params;
- (NSMutableURLRequest *)newRequestForGET:(NSString *)relativeAPIPath params:(NSDictionary *)params;
- (NSMutableURLRequest *)newRequestForPUT:(NSString *)relativeAPIPath params:(NSDictionary *)params andAttachment:(AttachmentTransfer *)attachment;
- (NSMutableURLRequest *)newRequestForJSON:(NSString *)path params:(NSDictionary *)params;
- (NSArray *)topJson:(NSString *)raw;
- (void)notifyDelegateDidFinish:(BOOL)success;
- (void)notifyDelegateOfPercentage:(float)percentage;
- (void)notifyDelegateOfTimeout;
- (BOOL)askDelegateIfShouldContinue;
- (void)finishBuildingResponse;
- (BOOL)finishBuildingJsonResponse:(NSString *)rawPayload;

@end


@implementation HTTPRequestService


@synthesize delegate;
@synthesize json;
@synthesize rawReturn;
@synthesize lastError;
@synthesize didFail;
@synthesize httpCode;
@synthesize returnType;
@synthesize responseUrl;
@synthesize userData;
@synthesize connection;
@synthesize receivedData;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[delegate release];
	[json release];
	[rawReturn release];
	[lastError release];
	[responseUrl release];
	[userData release];
	[connection release];
	[receivedData release];
	[super dealloc];
}


#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)aConnection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
	float percent = (totalBytesWritten * 1.0f) / (totalBytesExpectedToWrite * 1.0f);
	[self notifyDelegateOfPercentage:percent];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
	
	responseUrl = [[response URL] retain];
	 
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		httpCode = [(NSHTTPURLResponse *)response statusCode];
	}
	
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)anError {

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	switch (anError.code) {
	
		case -1009: // unexpected network connection
			[self setLastError:nil];
			break;
		
		case -1001: // time out
			[self setLastError:anError];
			[self notifyDelegateOfTimeout];
			return;
		
		default:
			[self setLastError:anError];
			break;
	}
	
	[self setConnection:nil];
	[self setReceivedData:nil];
	[self notifyDelegateDidFinish:NO];
	[self release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if (httpCode == 0 || httpCode == 200) {
		
		[self finishBuildingResponse];
		
	} else {
		
		if([self askDelegateIfShouldContinue]) {
		
			[self finishBuildingResponse];
		}
	}
	
	[self setConnection:nil];
	[self setReceivedData:nil];
	[self release];
}


#pragma mark -
#pragma mark HTTPRequestService
- (void)beginRequest:(NSString *)path
			  method:(HTTPRequestServiceMethod)method
			  params:(NSDictionary *)params
	  withReturnType:(HTTPRequestServiceReturnType)expectedReturnType {
	
	[self beginRequest:path method:method params:params withReturnType:expectedReturnType withAttachment:nil];
}

- (void)beginRequest:(NSString *)path
			  method:(HTTPRequestServiceMethod)method
			  params:(NSDictionary *)params
	  withReturnType:(HTTPRequestServiceReturnType)expectedReturnType
	  withAttachment:(AttachmentTransfer *)attachment {
	
	[self retain];
	
	CandyStoreAppDelegate *app = [UIApplication thisApp];
	if (![app canReachInternet]) {
		[self notifyDelegateDidFinish:NO];
		return;
	}
	
	[self setLastError:nil];
	didFail = NO;
	returnType = expectedReturnType;
	
	NSMutableURLRequest *request;
	switch (method) {
		case HTTPRequestServiceMethodPost:
			request = [self newRequestForPOST:path params:params];
			break;
		case HTTPRequestServiceMethodPut:
			request = [self newRequestForPUT:path params:params andAttachment:attachment];
			break;
		case HTTPRequestServiceMethodJson:
			request = [self newRequestForJSON:path params:params];
			break;
		case HTTPRequestServiceMethodGet:
		default:
			request = [self newRequestForGET:path params:params];
			break;
	}
	
	NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[request release];
	
	if (aConnection) {
		
		NSMutableData *data = [[NSMutableData alloc] init];
		[self setReceivedData:data];
		[data release];
		[self setConnection:aConnection];
		[aConnection release];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[connection start];
		
	} else {
		NSLog(@"Error connecting");
		[self notifyDelegateDidFinish:NO];
	}
}


#pragma mark Private Extension
- (void)setJson:(NSArray *)value {
	if ([json isEqualToArray:value]) return;
	[value retain];
	[json release];
	json = value;
}

- (void)setLastError:(NSError *)value {
	if ([lastError isEqual:value]) return;
	[value retain];
	[lastError release];
	lastError = value;
}

- (NSMutableURLRequest *)newRequestForPOST:(NSString *)path params:(NSDictionary *)params {
	
	NSURL *url = [NSURL URLWithString:path];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															timeoutInterval:kRequestTimeout];
	[request setHTTPMethod:@"POST"];
	
	NSString *paramsString = [params join];
	NSData *postData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:postData];
	
	return request;
}

- (NSMutableURLRequest *)newRequestForGET:(NSString *)path params:(NSDictionary *)params {
	
	NSString *paramsString = [params join];
	NSString *newPath = [NSString stringWithFormat:@"%@?%@", path, paramsString];
	NSURL *url = [NSURL URLWithString:newPath];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															timeoutInterval:kRequestTimeout];
	[request setHTTPMethod:@"GET"];
	
	return request;
}

- (NSMutableURLRequest *)newRequestForPUT:(NSString *)path params:(NSDictionary *)params andAttachment:(AttachmentTransfer *)attachment {
	
	NSURL *url = [NSURL URLWithString:path];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															timeoutInterval:kRequestTimeout];
	[request setHTTPMethod:@"PUT"];
	
	[HTTPMultipartBuilder setRequest:request withParameters:params withAttachment:attachment];
	
	return request;
}

- (NSMutableURLRequest *)newRequestForJSON:(NSString *)path params:(NSDictionary *)params {
	
	NSURL *url = [NSURL URLWithString:path];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url
																cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
															timeoutInterval:kRequestTimeout];
	[request setHTTPMethod:@"POST"];
	
	NSString *paramsString = [params JSONRepresentation];
	NSData *postData = [paramsString dataUsingEncoding:NSUTF8StringEncoding];
	[request setHTTPBody:postData];
	
	NSString *length = [[NSNumber numberWithInteger:paramsString.length] stringValue];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:length forHTTPHeaderField:@"Content-Length"];
	
	return request;
}

- (NSArray *)topJson:(NSString *)raw {
	id data = [raw JSONValue];
	if (!data) return nil;
	if ([data isKindOfClass:[NSArray class]]) return data;
	return [NSArray arrayWithObject:data];
}

- (void)notifyDelegateDidFinish:(BOOL)success {
	
	didFail = !success;
	
	if (!delegate) return;
	if (![delegate conformsToProtocol:@protocol(HTTPRequestServiceDelegate)]) return;
	
	[delegate httpRequestServiceDidFinish:self];
}

- (void)notifyDelegateOfTimeout {
	
	if (!delegate) return;
	if (![delegate conformsToProtocol:@protocol(HTTPRequestServiceDelegate)]) return;
	
	[delegate httpRequestServiceDidTimeout:self];
}

- (void)notifyDelegateOfPercentage:(float)percentage {
	
	if (!delegate) return;
	if (![delegate respondsToSelector:@selector(httpRequestService:didSendPercentage:)]) return;
	
	[delegate httpRequestService:self didSendPercentage:percentage];
}

- (BOOL)askDelegateIfShouldContinue {

	if (!delegate) return YES;
	if (![delegate respondsToSelector:@selector(httpRequestServiceShouldContinueAfterHttpCode:)]) return YES;
	
	return [delegate httpRequestServiceShouldContinueAfterHttpCode:self];
}

- (void)finishBuildingResponse {

	NSString *payloadAsString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
	
//	const int max = 100;
//	NSString *log; 
//	if (payloadAsString.length > max) {
//		log = [NSString stringWithFormat:@"%@ ...", [payloadAsString substringToIndex:max]];
//	} else {
//		log = payloadAsString;
//	}
//	NSLog(@"payload: %@", log);
		
	BOOL win = YES;
	switch (returnType) {
		case HTTPRequestServiceReturnTypeJson:
			win = [self finishBuildingJsonResponse:payloadAsString];
			break;
		case HTTPRequestServiceReturnTypeHtml: {
			rawReturn = [payloadAsString retain];
			break;
		}
		default:
			break;
	}

	[self notifyDelegateDidFinish:win];
	
	[payloadAsString release];
}

- (BOOL)finishBuildingJsonResponse:(NSString *)rawPayload {
	
	NSArray *top = [self topJson:rawPayload];
	[self setJson:top];
	
	return (top != nil);
}

@end
