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
#import "UIApplication+delegate.h"
#import "CandyStoreAppDelegate.h"
#import "NSObject+popup.h"
#import "UITableViewCell+activity.h"
#import "NSObject+remoteErrorToApp.h"


@interface CandyExchangeViewController()

@property (nonatomic, strong) NSIndexPath *waitingIndexPath;
@property (nonatomic, readonly) BOOL hasCredits;

@end


@implementation CandyExchangeViewController


#pragma mark -
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
		cell = _exchangeListItemCell;
		[self setExchangeListItemCell:nil];
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
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) return nil;
	if (![self hasCredits]) return nil;
	
	return indexPath;
}

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
	
	[self setWaitingIndexPath:indexPath];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setActivityIndicatorAccessoryView:UIActivityIndicatorViewStyleGray];
	[cell setActivityIndicatorAnimating:YES];
	[self.navigationController.view setUserInteractionEnabled:NO];
	
	ExchangeItem *exchangeItem = (ExchangeItem *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	Product *product = exchangeItem.product;
	
	ExchangeUseCreditRemoteService *service = [[ExchangeUseCreditRemoteService alloc] init];
	[service setDelegate:self];
	[service beginUseCreditForProduct:product];
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
	
	if ([product.parent.internalKey isEqualToString:InternalKeyExchange]) {
		
		[cell.titleLabel setText:NSLocalizedString(@"Available Credits", @"Available Credits")];
		
	} else {
		
		[cell.titleLabel setText:product.title];
	}
	
	UITableViewCellSelectionStyle style = ((indexPath.section == 0) || ![self hasCredits])
	? UITableViewCellSelectionStyleNone
	: UITableViewCellSelectionStyleGray;
	
	[cell setSelectionStyle:style];
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	UIImage *image = [service cachedImageAtPath:product.imagePath];
	if (!image) {
		
		[service setDelegate:self];
		[service beginLoadingImageAtPath:product.imagePath withUserData:indexPath];
		
	} else {
		
		[cell.iconView setImage:image];
	}
}

- (void)resetFetchedResultsController {
	
	ExchangeItemRepository *repo = [[ExchangeItemRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForExchangeView];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
}


#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	
	[self finishCredit];
	[self passFailedAuthenticationNotificationToAppDelegate:sender];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	
	[self finishCredit];
	[self passTimeoutNotificationToAppDelegate:sender];
}


#pragma mark ExchangeUseCreditRemoteServiceDelegate
- (void)exchangeUseCreditRemoteServiceDidUseCredit:(ExchangeUseCreditRemoteService *)sender {

	[self finishCredit];
	
	CandyStoreAppDelegate *app = [UIApplication thisApp];
	[app updateExchange];
}

- (void)exchangeUseCreditRemoteServiceFailedUsingCredit:(ExchangeUseCreditRemoteService *)sender {
	
	[self finishCredit];
	[self popup:NSLocalizedString(@"An error occurred while using a credit", @"An error occurred while using a credit")];
}


#pragma mark -
#pragma mark CandyExchangeViewController
#pragma mark Private Messages
- (BOOL)hasCredits {
	
	ExchangeItemRepository *repo = [[ExchangeItemRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	ExchangeItem *item = [repo creditsItem];
	return [item.quantityAvailable integerValue] > 0;
}

- (void)finishCredit {
	
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_waitingIndexPath];
	[cell clearAccessoryViewWith:UITableViewCellAccessoryNone];
	[self setWaitingIndexPath:nil];	
	[self.navigationController.view setUserInteractionEnabled:YES];
}


@end

