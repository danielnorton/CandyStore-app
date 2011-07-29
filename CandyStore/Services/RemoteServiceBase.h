//
//  RemoteServiceBase.h
//
//  Created by Daniel Norton on 3/3/11.
//

#import "HTTPRequestService.h"


@class RemoteServiceBase;


@protocol RemoteServiceDelegate <NSObject>

- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender;
- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender;

@end


@interface RemoteServiceBase : NSObject <HTTPRequestServiceDelegate>

@property (nonatomic, retain) id<RemoteServiceDelegate> delegate;
@property (nonatomic, retain) NSString *replyText;
@property (nonatomic, assign) int replyCode;
@property (nonatomic, assign) int expectedReplyCode;
@property (nonatomic, assign) HTTPRequestServiceMethod method;
@property (nonatomic, assign) HTTPRequestServiceReturnType returnType;

- (void)beginRemoteCallWithPath:(NSString *)path withParams:(NSDictionary *)params withUserData:(id)userData;
- (void)buildModelFromSuccess:(HTTPRequestService *)sender;

- (void)notifyDelegateOfFailedAuthentication;
- (void)notifyDelegateOfTimeout;
- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender;


@end

