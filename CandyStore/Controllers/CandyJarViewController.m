//
//  CandyJarViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyJarViewController.h"

@implementation CandyJarViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self.navigationController setNavigationBarHidden:YES];
}

@end
