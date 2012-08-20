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
#import "UIViewController+newWithDefaultNib.h"
#import "ShopItemDetailViewController.h"
#import "UITableViewCell+activity.h"
#import "CandyShopService.h"


@implementation CandyShopViewController

@synthesize shopListItemCell;
@synthesize restoreButton;


#pragma mark -
#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setShopListItemCell:nil];
	[self setRestoreButton:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[restoreButton setEnabled:[CandyShopService isStoreKitEnabled]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ([self shouldShowRefreshingCell]) {
		
		return [self refreshingCellForTableView:tableView];
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
	
	id<NSFetchedResultsSectionInfo> info = (self.fetchedResultsController.sections)[section];
	int productKind = [[info indexTitle] integerValue];
	
	if (productKind != ProductKindCandy) return nil;
	
	return NSLocalizedString(@"Candy", @"Candy");
}


#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return [ShopListItemCell defaultHeight];
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
}


#pragma mark ImageCachingServiceDelegate
- (void)imageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	[self reloadVisibleCells];
}


#pragma RefreshingTableViewController
- (void)configureCell:(UITableViewCell *)aCell atIndexPath:(NSIndexPath *)indexPath {
	
	ShopListItemCell *cell = (ShopListItemCell *)aCell;
	if (![cell isKindOfClass:[ShopListItemCell class]]) return;
		  
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.titleLabel setText:product.title];
	
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
}

- (void)completeRefreshing {
	[super completeRefreshing];
	
	if (restoreButton.isEnabled) {
		
		[restoreButton setEnabled:[CandyShopService isStoreKitEnabled]];
	}
}

- (void)resetFetchedResultsController {

	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForCandyShop];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
}

@end

