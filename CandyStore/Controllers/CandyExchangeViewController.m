//
//  CandyExchangeViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyExchangeViewController.h"
#import "Model.h"
#import "ExchangeItemRepository.h"
#import "Style.h"
#import "CandyShopService.h"


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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if	(self.fetchedResultsController.sections.count == 0) return nil;
	
	id<NSFetchedResultsSectionInfo> info = [self.fetchedResultsController.sections objectAtIndex:section];
	int productKind = [[info indexTitle] integerValue];
	
	if (productKind != ProductKindCandy) return nil;
	
	return NSLocalizedString(@"Candy", @"Candy");
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
	ExchangeItem *exchangeItem = (ExchangeItem *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	Product *product = exchangeItem.product;
	
	[cell.quantityLabel setText:[exchangeItem.quantityAvailable stringValue]];
	
	if ([product.internalKey isEqualToString:InternalKeyExchange]) {
		
		[cell.titleLabel setText:NSLocalizedString(@"Available Credits", @"Available Credits")];
		
	} else {
		
		[cell.titleLabel setText:product.title];
	}
	
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
	
	ExchangeItemRepository *repo = [[ExchangeItemRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForExchangeView];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
	[repo release];
}


@end
