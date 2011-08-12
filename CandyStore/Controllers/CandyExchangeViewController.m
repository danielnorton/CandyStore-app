//
//  CandyExchangeViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyExchangeViewController.h"
#import "Model.h"
#import "ProductRepository.h"
#import "Style.h"


@implementation CandyExchangeViewController

@synthesize exchangeListItemCell;


#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[exchangeListItemCell release];
	[super dealloc];
}


#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setExchangeListItemCell:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([self shouldShowRefreshingCell]) {
		
		return [self refreshingCellForTableView:tableView];
	}
	
	static NSString *identifier = @"exchangeListItemCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		
		[[NSBundle mainBundle] loadNibNamed:@"ExchangeListItemCell" owner:self options:nil];
		cell = exchangeListItemCell;
		[self setExchangeListItemCell:nil];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return [ExchangeListItemCell defaultHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([self shouldShowRefreshingCell]) return;
	
	if ((indexPath.row % 2) == 1) {
		
		[cell setBackgroundColor:[UIColor darkGrayStoreColor]];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark ImageCachingServiceDelegate
- (void)imageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	[self reloadVisibleCells];
}


#pragma RefreshingTableViewController
- (void)configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath {
	
	ExchangeListItemCell *cell = (ExchangeListItemCell *)aCell;
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.titleLabel setText:product.title];
	[cell.quantityLabel setText:[product.exchangeItem.quantityAvailable stringValue]];
	
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

- (void)resetFetchedResultsController {
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForCandyShop];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
	[repo release];
}


@end
