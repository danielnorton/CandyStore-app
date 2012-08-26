//
//  NSObject+remoteErrorToApp.m
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "NSObject+remoteErrorToApp.h"
#import "UIApplication+delegate.h"


@implementation NSObject(remoteErrorToApp)

- (void)passFailedAuthenticationNotificationToAppDelegate:(RemoteServiceBase *)sender {
	
	id<RemoteServiceDelegate> delegate = [UIApplication thisApp];
	[delegate remoteServiceDidFailAuthentication:sender];
}

- (void)passTimeoutNotificationToAppDelegate:(RemoteServiceBase *)sender {

	id<RemoteServiceDelegate> delegate = [UIApplication thisApp];
	[delegate remoteServiceDidTimeout:sender];
}

@end
