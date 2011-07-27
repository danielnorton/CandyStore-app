//
//  HTTPRequestService.h
// 
//
//  Created by Daniel Norton on 11/19/10.
//  Copyright 2010 Bandit Software. All rights reserved.
//

#import "AttachmentTransfer.h"

typedef BOOL (^ReachabilityTest)();

typedef enum {
	HTTPRequestServiceMethodUnknown,
	HTTPRequestServiceMethodPost,
	HTTPRequestServiceMethodGet,
	HTTPRequestServiceMethodPut,
	HTTPRequestServiceMethodJson
} HTTPRequestServiceMethod;


typedef enum {
	HTTPRequestServiceReturnTypeUnknown,
	HTTPRequestServiceReturnTypeJson,
	HTTPRequestServiceReturnTypeHtml,
} HTTPRequestServiceReturnType;


@class HTTPRequestService;


@protocol HTTPRequestServiceDelegate <NSObject>
- (void)httpRequestServiceDidFinish:(HTTPRequestService *)sender;
- (void)httpRequestServiceDidTimeout:(HTTPRequestService *)sender;
@optional
- (BOOL)httpRequestServiceShouldContinueAfterHttpCode:(HTTPRequestService *)sender;
- (void)httpRequestService:(HTTPRequestService *)sender didSendPercentage:(float)percentage;
@end


@interface HTTPRequestService : NSObject

@property (nonatomic, retain) id<HTTPRequestServiceDelegate> delegate;
@property (nonatomic, readonly) NSArray *json;
@property (nonatomic, readonly) NSString *rawReturn;
@property (nonatomic, readonly) NSError *lastError;
@property (nonatomic, readonly) BOOL didFail;
@property (nonatomic, readonly) int httpCode;
@property (nonatomic, readonly) HTTPRequestServiceReturnType returnType;
@property (nonatomic, readonly) NSURL *responseUrl;
@property (nonatomic, retain) id userData;

+ (void)setReachabilityTest:(ReachabilityTest)test;
+ (ReachabilityTest)reachabilityTest;

- (void)beginRequest:(NSString *)path
			  method:(HTTPRequestServiceMethod)method
			  params:(NSDictionary *)params
	  withReturnType:(HTTPRequestServiceReturnType)expectedReturnType;

- (void)beginRequest:(NSString *)path
			  method:(HTTPRequestServiceMethod)method
			  params:(NSDictionary *)params
	  withReturnType:(HTTPRequestServiceReturnType)expectedReturnType
	  withAttachment:(AttachmentTransfer *)attachment;


@end

