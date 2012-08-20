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

@property (nonatomic, strong) NSMutableData *receivedData;

@end

@implementation HTTPRequestService


#pragma mark -
#pragma mark NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
	
	float percent = (totalBytesWritten * 1.0f) / (totalBytesExpectedToWrite * 1.0f);
	[self notifyDelegateOfPercentage:percent];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
	_responseUrl = [response URL];
	 
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		_httpCode = [(NSHTTPURLResponse *)response statusCode];
	}
	
	[_receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	[_receivedData appendData:data];
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
	
	if (_httpCode == 0 || _httpCode == 200) {
		
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
	_didFail = NO;
	_returnType = expectedReturnType;
	
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
	
	if (connection) {
		
		NSMutableData *data = [[NSMutableData alloc] init];
		[self setReceivedData:data];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		[connection start];
		
	} else {
		NSLog(@"Error connecting");
		[self notifyDelegateDidFinish:NO];
	}
}


#pragma mark Private Messages
- (void)setJson:(NSArray *)value {
	if ([_json isEqualToArray:value]) return;
	_json = value;
}

- (void)setLastError:(NSError *)value {
	if ([_lastError isEqual:value]) return;
	_lastError = value;
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
	
	NSString *length = [NSString stringWithFormat:@"%i", paramsString.length];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setValue:length forHTTPHeaderField:@"Content-Length"];
	
	return request;
}

- (NSArray *)topJson:(NSString *)raw {
	id data = [raw JSONValue];
	if (!data) return nil;
	if ([data isKindOfClass:[NSArray class]]) return data;
	return @[data];
}

- (void)notifyDelegateDidFinish:(BOOL)success {
	
	_didFail = !success;
	
	if (!_delegate) return;
	if (![_delegate conformsToProtocol:@protocol(HTTPRequestServiceDelegate)]) return;
	
	[_delegate httpRequestServiceDidFinish:self];
}

- (void)notifyDelegateOfTimeout {
	
	if (!_delegate) return;
	if (![_delegate conformsToProtocol:@protocol(HTTPRequestServiceDelegate)]) return;
	
	[_delegate httpRequestServiceDidTimeout:self];
}

- (void)notifyDelegateOfPercentage:(float)percentage {
	
	if (!_delegate) return;
	if (![_delegate respondsToSelector:@selector(httpRequestService:didSendPercentage:)]) return;
	
	[_delegate httpRequestService:self didSendPercentage:percentage];
}

- (BOOL)askDelegateIfShouldContinue {

	if (!_delegate) return YES;
	if (![_delegate respondsToSelector:@selector(httpRequestServiceShouldContinueAfterHttpCode:)]) return YES;
	
	return [_delegate httpRequestServiceShouldContinueAfterHttpCode:self];
}

- (void)finishBuildingResponse {

	NSString *payloadAsString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
	
//	const int max = 100;
//	NSString *log; 
//	if (payloadAsString.length > max) {
//		log = [NSString stringWithFormat:@"%@ ...", [payloadAsString substringToIndex:max]];
//	} else {
//		log = payloadAsString;
//	}
//	NSLog(@"payload: %@", log);
		
	BOOL win = YES;
	switch (_returnType) {
		case HTTPRequestServiceReturnTypeJson:
			win = [self finishBuildingJsonResponse:payloadAsString];
			break;
		case HTTPRequestServiceReturnTypeHtml: {
			_rawReturn = payloadAsString;
			break;
		}
		default:
			break;
	}

	[self notifyDelegateDidFinish:win];
	
}

- (BOOL)finishBuildingJsonResponse:(NSString *)rawPayload {
	
	NSArray *top = [self topJson:rawPayload];
	[self setJson:top];
	
	return (top != nil);
}

@end
