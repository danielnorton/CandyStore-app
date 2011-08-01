//
//  CandyShopViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

 #import <QuartzCore/QuartzCore.h>
#import "CandyShopViewController.h"
#import "Model.h"
#import "ProductRepository.h"


@implementation CandyShopViewController

@synthesize shopItemCell;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[shopItemCell release];
	[super dealloc];
}


#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setShopItemCell:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	NSError *error = nil;
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForAll];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
	[repo release];
	
	if ([self shouldShowRefreshingCell]) return;
	if (![self.fetchedResultsController performFetch:&error]) {
		
		// TODO: handle error
		[self.fetchedResultsController setDelegate:nil];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([self shouldShowRefreshingCell]) {
		
		static NSString *refreshingCellIdentifier = @"refreshingCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:refreshingCellIdentifier];
		if (!cell) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:refreshingCellIdentifier] autorelease];
		}
		
		[self configureRefreshingCell:cell];
		return cell;
	}
	
	static NSString *identifier = @"shopItemCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {

		[[NSBundle mainBundle] loadNibNamed:@"ShopItemCell" owner:self options:nil];
		cell = shopItemCell;
		[self setShopItemCell:nil];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}


#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 66.0f;
}


#pragma mark ImageCachingServiceDelegate
- (void)ImageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	[self reloadVisibleCells];
}


#pragma RefreshingTableViewController
- (void)configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath {
	
	ShopItemCell *cell = (ShopItemCell *)aCell;
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.buyButton setTitle:@"$123.99" forState:UIControlStateNormal];
	[cell.buyButton setTitle:NSLocalizedString(@"BUY NOW", @"BUY NOW") forState:UIControlStateSelected];
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	UIImage *image = [service cachedImageAtPath:product.imagePath];
	if (!image) {
		
		[service setDelegate:self];
		[service beginLoadingImageAtPath:product.imagePath withUserData:indexPath];
		
	} else {
		
		[cell.iconView setImage:image];
	}
	
	[service release];
}


@end


