//
//  RemoteServiceBase.h
//  LeanKit
//
//  Created by Daniel Norton on 3/3/11.
//  Copyright 2011 Bandit Software. All rights reserved.
//

#import "HTTPRequestService.h"

typedef enum {
	
	RemoteServiceErrorExceedsWIP = 900
	
} RemoteServiceKnownErrorCodes;


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
- (NSArray *)buildModelFromJson:(NSArray *)json;

- (void)notifyDelegateOfFailedAuthentication;
- (void)notifyDelegateOfTimeout;
- (void)notifyDelegateOfFailure:(HTTPRequestService *)sender;


@end

