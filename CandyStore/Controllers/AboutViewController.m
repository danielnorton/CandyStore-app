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


@interface AboutViewController()

- (void)dismissMe;

@end


@implementation AboutViewController


@synthesize appNameLabel;
@synthesize versionLabel;
@synthesize storeKitLabel;

#pragma mark -
#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setAppNameLabel:nil];
	[self setVersionLabel:nil];
	[self setStoreKitLabel:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[appNameLabel setText:[UIApplication appName]];
	
	NSString *number = [UIApplication version];
	NSString *word = NSLocalizedString(@"Version", @"Version");
	NSString *message = [NSString stringWithFormat:@"%@: %@", word, number];
	[versionLabel setText:message];
	
	NSString *storeOn = NSLocalizedString(@"StoreKit is enabled", @"StoreKit is enabled");
	NSString *storeOff = NSLocalizedString(@"StoreKit is not enabled", @"StoreKit is not enabled");
	NSString *storeMessage = [CandyShopService isStoreKitEnabled]
	? storeOn
	: storeOff;
	[storeKitLabel setText:storeMessage];
	
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMe)];
	[self.view addGestureRecognizer:tap];
}


#pragma mark -
#pragma mark AboutViewController
#pragma mark Private Extension
- (void)dismissMe {
	
	[self dismissModalViewControllerAnimated:YES];
}


@end

