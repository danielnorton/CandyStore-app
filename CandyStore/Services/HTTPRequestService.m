//
//  HTTPRequestService.m
// 
//
//  Created by Daniel Norton on 11/19/10.
//

#import "HTTPRequestService.h"
#import "SBJson.h"
#import "NSDictionary+join.h"
#import "HTTPMultipartBuilder.h"
#import "NSURLRequest+cert.h"
#import "SelfReferenceService.h"


#define kRequestTimeout 15.0f


@interface HTTPRequestService()

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
@synthesize receivedData;



#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[json release];
	[rawReturn release];
	[lastError release];
	[responseUrl release];
	[userData release];
	[receivedData release];
	[super dealloc];
}


#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
	float percent = (totalBytesWritten * 1.0f) / (totalBytesExpectedToWrite * 1.0f);
	[self notifyDelegateOfPercentage:percent];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	responseUrl = [[response URL] retain];
	 
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		httpCode = [(NSHTTPURLResponse *)response statusCode];
	}
	
	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)anError {

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
	
	[SelfReferenceService remove:connection];
	[self setReceivedData:nil];
	[self notifyDelegateDidFinish:NO];
	[SelfReferenceService remove:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	if (httpCode == 0 || httpCode == 200) {
		
		[self finishBuildingResponse];
		
	} else {
		
		if([self askDelegateIfShouldContinue]) {
		
			[self finishBuildingResponse];
		}
	}
	
	[SelfReferenceService remove:connection];
	[self setReceivedData:nil];
	[SelfReferenceService remove:self];
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

	[SelfReferenceService add:self];
	
	[self setLastError:nil];
	didFail = NO;
	returnType = expectedReturnType;
	
	NSMutableURLRequest *request;
	switch (method) {
			
		case HTTPRequestServiceMethodPost: {
			
			request = [self newRequestForPOST:path params:params];
			break;
		}
			
		case HTTPRequestServiceMethodPut: {
			
			request = [self newRequestForPUT:path params:params andAttachment:attachment];
			break;
		}
			
		case HTTPRequestServiceMethodPostJson: {
			
			request = [self newRequestForJSON:path params:params];
			break;
		}
			
		case HTTPRequestServiceMethodPutJson: {
			
			request = [self newRequestForJSON:path params:params];
			[request setHTTPMethod:@"PUT"];
			break;
		}

		case HTTPRequestServiceMethodGet:
		default: {

			request = [self newRequestForGET:path params:params];
			break;
		}
	}
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[SelfReferenceService add:connection];
	[request release];
	
	if (connection) {
		
		NSMutableData *data = [[NSMutableData alloc] init];
		[self setReceivedData:data];
		[data release];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[connection start];
		[connection release];
		
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
