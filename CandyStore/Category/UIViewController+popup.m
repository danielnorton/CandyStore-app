//
//  UIViewController+popup.m
// 
//
//  Created by Daniel Norton on 10/19/10.
//  Copyright 2011 Firefly Logic. All rights reserved.
//

#import "UIViewController+popup.h"
#import "UIApplication+delegate.h"

@implementation UIViewController(popup)

- (void)popup:(NSString *)message {
	[self popup:message withDelegate:nil];
}

- (void)popup:(NSString *)message withDelegate:(id<UIAlertViewDelegate>)delegate {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[UIApplication appName]
													message:message
												   delegate:delegate
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

@end
