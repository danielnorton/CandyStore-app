//
//  HTTPRequestService.h
// 
//
//  Created by Daniel Norton on 11/19/10.
//

#import "AttachmentTransfer.h"


typedef NS_ENUM(uint, HTTPRequestServiceMethod) {
	HTTPRequestServiceMethodUnknown,
	HTTPRequestServiceMethodPost,
	HTTPRequestServiceMethodGet,
	HTTPRequestServiceMethodPut,
	HTTPRequestServiceMethodPostJson,
	HTTPRequestServiceMethodPutJson
};


typedef NS_ENUM(uint, HTTPRequestServiceReturnType) {
	HTTPRequestServiceReturnTypeUnknown,
	HTTPRequestServiceReturnTypeJson,
	HTTPRequestServiceReturnTypeHtml,
};


@class HTTPRequestService;


@protocol HTTPRequestServiceDelegate <NSObject>
- (void)httpRequestServiceDidFinish:(HTTPRequestService *)sender;
- (void)httpRequestServiceDidTimeout:(HTTPRequestService *)sender;
@optional
- (BOOL)httpRequestServiceShouldContinueAfterHttpCode:(HTTPRequestService *)sender;
- (void)httpRequestService:(HTTPRequestService *)sender didSendPercentage:(float)percentage;
@end


@interface HTTPRequestService : NSObject

@property (nonatomic, weak) id<HTTPRequestServiceDelegate> delegate;
@property (weak, nonatomic, readonly) NSArray *json;
@property (nonatomic, readonly) NSString *rawReturn;
@property (weak, nonatomic, readonly) NSError *lastError;
@property (nonatomic, readonly) BOOL didFail;
@property (nonatomic, readonly) int httpCode;
@property (nonatomic, readonly) HTTPRequestServiceReturnType returnType;
@property (nonatomic, readonly) NSURL *responseUrl;
@property (nonatomic, strong) id userData;


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

