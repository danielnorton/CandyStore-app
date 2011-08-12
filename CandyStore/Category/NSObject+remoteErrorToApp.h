//
//  NSObject+remoteErrorToApp.h
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//


#import "RemoteServiceBase.h"


@interface NSObject(remoteErrorToApp)

- (void)passFailedAuthenticationNotificationToAppDelegate:(RemoteServiceBase *)sender;
- (void)passTimeoutNotificationToAppDelegate:(RemoteServiceBase *)sender;

@end
