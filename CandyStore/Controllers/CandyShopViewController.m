//
//  CandyShopViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyShopViewController.h"
#import "Model.h"
#import "ProductRepository.h"
#import "Style.h"
#import "UITableViewCell+activity.h"
#import "UIViewController+newWithDefaultNib.h"
#import "ShopItemDetailViewController.h"

#define kShopListItemCellHeight 66.0f

@interface CandyShopViewController()

- (void)resetFetchedResultsController;

@end


@implementation CandyShopViewController

@synthesize shopListItemCell;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[shopListItemCell release];
	[super dealloc];
}


#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setShopListItemCell:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];

	[self.tableView setSeparatorColor:[UIColor shopTableSeperatorColor]];
	
	[self resetFetchedResultsController];
	if ([self shouldShowRefreshingCell]) return;
	
	NSError *error = nil;	
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
	
	static NSString *identifier = @"shopListItemCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {

		[[NSBundle mainBundle] loadNibNamed:@"ShopListItemCell" owner:self options:nil];
		cell = shopListItemCell;
		[self setShopListItemCell:nil];
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
	
	return kShopListItemCellHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([self shouldShowRefreshingCell]) return;
	
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	if ((product.kind == ProductKindCandy) && ((indexPath.row % 2) == 1)) {
		
		[cell setBackgroundColor:[UIColor darkGrayStoreColor]];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	ShopItemDetailViewController *controller = [ShopItemDetailViewController newWithDefaultNib];
	[controller setProduct:product];
	
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}


#pragma mark ImageCachingServiceDelegate
- (void)imageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	[self reloadVisibleCells];
}


#pragma RefreshingTableViewController
- (void)configureRefreshingCell:(UITableViewCell *)cell {

	[super configureRefreshingCell:cell];
	[cell setActivityIndicatorAccessoryView:UIActivityIndicatorViewStyleWhite];
	[cell.textLabel setTextColor:[UIColor whiteColor]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void)configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath {
	
	ShopListItemCell *cell = (ShopListItemCell *)aCell;
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.titleLabel setText:product.title];
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	if (product.localizedPrice) {
		
		[cell.priceLabel setHidden:NO];
		[cell.priceLabel setText:product.localizedPrice];
		
	} else {
		
		[cell.priceLabel setHidden:YES];
		[cell.priceLabel setText:nil];
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


#pragma mark -
#pragma mark CandyShopViewController
- (void)presentDataError:(NSString *)message {
	
	[self enableWithLoadingCellMessage:message];
	[self resetFetchedResultsController];
}


#pragma mark Private Extension
- (void)resetFetchedResultsController {

	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForCandyShop];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
	[repo release];
}

@end

