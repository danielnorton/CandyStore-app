//
//  CandyJarViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyJarViewController.h"
#import "Model.h"
#import "PurchaseRepository.h"


#define kWelcomeViewTag -9999

@interface CandyJarViewController()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)loadWelcomeView;

@end


@implementation CandyJarViewController

@synthesize welcomeView;
@synthesize tableView;
@synthesize fetchedResultsController;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[welcomeView release];
	[tableView release];
	[fetchedResultsController release];
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
	
	NSError *error = nil;
	PurchaseRepository *repo = [[PurchaseRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForMyCandyJar];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
	[repo release];
	
	if (![fetchedResultsController performFetch:&error]) {
		
		// TODO: handle error
		[fetchedResultsController setDelegate:nil];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	[self.navigationController setNavigationBarHidden:YES];
	
	int count = [fetchedResultsController.managedObjectContext countForFetchRequest:fetchedResultsController.fetchRequest error:nil];
	BOOL hasSome = (count > 0);
	BOOL wasHidden = !welcomeView.isHidden;
	[welcomeView setHidden:hasSome];
	
	if (wasHidden) {
		
		[tableView reloadData];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	id<NSFetchedResultsSectionInfo> info = [fetchedResultsController.sections objectAtIndex:section];
	return [info numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"MyCell";

    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }

	Purchase *purchase = (Purchase *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:purchase.product.title];

    return cell;
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
