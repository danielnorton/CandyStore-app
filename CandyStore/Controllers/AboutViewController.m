//
//  AboutViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 8/13/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "AboutViewController.h"
#import "CandyShopService.h"
#import "UIApplication+delegate.h"


@implementation AboutViewController

#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[_appNameLabel setText:[UIApplication appName]];
	
	NSString *number = [UIApplication version];
	NSString *word = NSLocalizedString(@"Version", @"Version");
	NSString *message = [NSString stringWithFormat:@"%@: %@", word, number];
	[_versionLabel setText:message];
	
	NSString *storeOn = NSLocalizedString(@"StoreKit is enabled", @"StoreKit is enabled");
	NSString *storeOff = NSLocalizedString(@"StoreKit is not enabled", @"StoreKit is not enabled");
	NSString *storeMessage = [CandyShopService isStoreKitEnabled]
	? storeOn
	: storeOff;
	[_storeKitLabel setText:storeMessage];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMe)];
	[self.view addGestureRecognizer:tap];
}


#pragma mark -
#pragma mark AboutViewController
#pragma mark Private Messages
- (void)dismissMe {

	[self dismissViewControllerAnimated:YES completion:NULL];
}


@end

