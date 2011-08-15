//
//  NSObject+remoteErrorToApp.m
//  CandyStore
//
//  Created by Daniel Norton on 8/12/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "NSObject+remoteErrorToApp.h"
#import "UIApplication+delegate.h"


@implementation RemoteServiceBase(remoteErrorToApp)

- (void)passFailedAuthenticationNotificationToAppDelegate {
	
//	id<RemoteServiceDelegate> delegate = [UIApplication thisApp];
//	[delegate remoteServiceDidFailAuthentication:self];
}

- (void)passTimeoutNotificationToAppDelegate {

//	id<RemoteServiceDelegate> delegate = [UIApplication thisApp];
//	[delegate remoteServiceDidTimeout:self];
}

@end
