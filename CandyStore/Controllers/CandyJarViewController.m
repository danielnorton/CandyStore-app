//
//  CandyJarViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyJarViewController.h"
#import "CandyShopService.h"

#define kWelcomeViewTag -9999

@interface CandyJarViewController()

- (void)loadWelcomeView;

@end


@implementation CandyJarViewController

@synthesize welcomeView;
@synthesize tableView;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[welcomeView release];
	[tableView release];
	[super dealloc];
}


#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setWelcomeView:nil];
	[self setTableView:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.view addSubview:tableView];
	[self loadWelcomeView];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	[self.navigationController setNavigationBarHidden:YES];
	[welcomeView setHidden:[CandyShopService hasCandy]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}


#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}


#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[UIView animateWithDuration:0.33f animations:^(void) {
		
		[welcomeView setAlpha:1.0f];
	}];
}


#pragma mark -
#pragma mark CandyJarViewController
#pragma mark Private Extension
- (void)loadWelcomeView {
	
	[welcomeView setTag:kWelcomeViewTag];
	[welcomeView setAlpha:0.0f];
	[welcomeView setHidden:YES];
	
	NSBundle *main = [NSBundle mainBundle];
	NSURL *url = [main URLForResource:@"index" withExtension:@"html" subdirectory:@"welcome"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[welcomeView loadRequest:request];
	[self.view addSubview:welcomeView];
}

@end
