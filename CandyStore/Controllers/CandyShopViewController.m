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


#pragma mark -
#pragma mark UIViewController
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
	
	NSLog(@"cellForRowAtIndexPath: row:%d section:%d", indexPath.row, indexPath.section);
	
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	NSString *identifier = [NSString stringWithFormat:@"%d", product.kind];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
		
		[cell.imageView.layer setMasksToBounds:YES];
		[cell.imageView.layer setCornerRadius:5.0f];
		[cell.imageView setImage:[UIImage imageNamed:@"shopPlaceholder"]];		
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if ([self shouldShowRefreshingCell]) return nil;
	
	id<NSFetchedResultsSectionInfo> info = [self.fetchedResultsController.sections objectAtIndex:section];
	int sectionKind = [[info name] integerValue];
	
	switch (sectionKind) {
			
		case ProductKindExchange:
			return NSLocalizedString(@"Candy Exchange", @"Candy Exchange");
			
		case ProductKindBigCandyJar:
			return NSLocalizedString(@"Big Candy Jar", @"Big Candy Jar");
			
		case ProductKindCandy:
			return NSLocalizedString(@"Candy", @"Candy");
			
		default:
			return nil;
	}
}


#pragma mark ImageCachingServiceDelegate
- (void)ImageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	[self reloadVisibleCells];
}


#pragma RefreshingTableViewController
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	[cell.textLabel setText:product.title];
	[cell.detailTextLabel setText:product.subTitle];
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	UIImage *image = [service cachedImageAtPath:product.imagePath];
	if (!image) {
		
		[service setDelegate:self];
		[service beginLoadingImageAtPath:product.imagePath withUserData:indexPath];
		
	} else {
		
		[cell.imageView setImage:image];
	}
	
	[service release];
}


@end


