//
//  CandyJarViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "CandyJarViewController.h"
#import "Model.h"
#import "ProductRepository.h"
#import "CandyShopService.h"
#import "Style.h"
#import "UITableViewDelgate+emptyFooter.h"
#import "CandyEatingService.h"
#import "NSObject+popup.h"
#import "NSObject+remoteErrorToApp.h"
#import "UIApplication+delegate.h"
#import "CandyStoreAppDelegate.h"
#import "UIViewController+newWithDefaultNib.h"
#import "TransactionDownloadService.h"
#import "ProductContentService.h"


@interface CandyJarViewController()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BOOL shouldEnableExchangeButtons;
@property (nonatomic, strong) UIBarButtonItem *bigJarDocumentButton;

@end


@implementation CandyJarViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[_tableView setSeparatorColor:[UIColor shopTableSeperatorColor]];
	
	[_welcomeView setAlpha:0.0f];
	[_welcomeView setOpaque:NO];
	[_tableView setAlpha:0.0f];
	
	[self loadWelcomeView];
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForMyCandyJar];
	[self setFetchedResultsController:controller];
	[self fetch];
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(didTapBigJarDocumentButton:)];
	[self setBigJarDocumentButton:button];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self showHideViews];
	
	[self resetShouldEnableExchangeButtons];
}

- (NSUInteger)supportedInterfaceOrientations {
	
	return UIInterfaceOrientationMaskAll;
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	id<NSFetchedResultsSectionInfo> info = (_fetchedResultsController.sections)[section];
	return [info numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"JarListItemCell";
    JarListItemCell *cell = (JarListItemCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
		
		[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
		cell = self.jarListItemCell;
		[self setJarListItemCell:nil];
		
		[cell.exchangeButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
		[cell.exchangeButton setTitleColor:[UIColor buyButtonTextColor] forState:UIControlStateNormal];
		[cell.exchangeButton setTitleShadowColor:[UIColor buyButtonShadowColor] forState:UIControlStateNormal];
		
		[cell.exchangeButton setTitleColor:[UIColor buyButtonDisabledTextColor] forState:UIControlStateDisabled];
		[cell.exchangeButton setTitleShadowColor:[UIColor buyButtonDisabledShadowColor] forState:UIControlStateDisabled];
		
		[cell.eatButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
		[cell.eatButton setTitleColor:[UIColor buyButtonTextColor] forState:UIControlStateNormal];
		[cell.eatButton setTitleShadowColor:[UIColor buyButtonShadowColor] forState:UIControlStateNormal];
		
		[cell.eatButton setTitleColor:[UIColor buyButtonDisabledTextColor] forState:UIControlStateDisabled];
		[cell.eatButton setTitleShadowColor:[UIColor buyButtonDisabledShadowColor] forState:UIControlStateDisabled];
		
		UIImage *blue = [[UIImage imageNamed:@"blueBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
		UIImage *green = [[UIImage imageNamed:@"greenBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
		UIImage *gray = [[UIImage imageNamed:@"grayBuyButton"] stretchableImageWithLeftCapWidth:10.0f topCapHeight:10.0f];
		
		[cell.exchangeButton setBackgroundColor:[UIColor clearColor]];
		[cell.exchangeButton setBackgroundImage:blue forState:UIControlStateNormal];
		[cell.exchangeButton setBackgroundImage:green forState:UIControlStateSelected];
		[cell.exchangeButton setBackgroundImage:gray forState:UIControlStateDisabled];
		
		[cell.eatButton setBackgroundColor:[UIColor clearColor]];
		[cell.eatButton setBackgroundImage:blue forState:UIControlStateNormal];
		[cell.eatButton setBackgroundImage:green forState:UIControlStateSelected];
		[cell.eatButton setBackgroundImage:gray forState:UIControlStateDisabled];
    }
	
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


#pragma mark UITableViewDelegate
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 115.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if ((indexPath.row % 2) == 1) {
		
		[cell setBackgroundColor:[UIColor darkGrayStoreColor]];
	}
}


#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[self showHideViews];
}


#pragma mark UIDocumentInteractionControllerDelegate
- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
	
	return self;
}


#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
	[self showHideViews];
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
	
	[self showHideViews];
	
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(JarListItemCell *)[_tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark ImageCachingServiceDelegate
- (void)imageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	[self reloadVisibleCells];
}


#pragma mark JarListItemCellDelegate
- (void)jarListItemCell:(JarListItemCell *)cell didEatOneProduct:(Product *)product {
	
	CandyEatingService *service = [[CandyEatingService alloc] init];
	[service eatCandy:product];
}

- (void)jarListItemCell:(JarListItemCell *)cell didExchangeOneProduct:(Product *)product {

	ExchangeAddCreditRemoteService *service = [[ExchangeAddCreditRemoteService alloc] init];
	[service setDelegate:self];
	[service beginAddingCreditFromPurchase:[product.purchases anyObject]];
}


#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	[self passFailedAuthenticationNotificationToAppDelegate:sender];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	[self passTimeoutNotificationToAppDelegate:sender];
}


#pragma mark ExchangeAddCreditRemoteServiceDelegate
- (void)exchangeAddCreditRemoteServiceFailedAddingCredit:(ExchangeAddCreditRemoteService *)sender {

	if (sender.code == ReceiptVerificationRemoteServiceCodeSubscriptionExpired) {
		
		NSString *message = @"Your Exchange subscription may have expired. Try refreshing the Candy Shop.";
		[self popup:NSLocalizedString(message, message)];
		
	} else {
		
		[self popup:NSLocalizedString(@"An error occurred while adding a credit to Exchange", @"An error occurred while adding a credit to Exchange")];
	}
}

- (void)exchangeAddCreditRemoteServiceDidAddCredit:(ExchangeAddCreditRemoteService *)sender {
	
	CandyStoreAppDelegate *app = [UIApplication thisApp];
	[app updateExchange];
}


#pragma mark -
#pragma mark CandyJarViewController
- (void)resetShouldEnableExchangeButtons {
	
	BOOL newEnable = [CandyShopService canAddToExchangeCredits];
	if (newEnable != _shouldEnableExchangeButtons) {
		
		[self setShouldEnableExchangeButtons:newEnable];
		[self.tableView reloadData];
	}
}


#pragma mark Private Messages
- (void)loadWelcomeView {
	
	NSBundle *main = [NSBundle mainBundle];
	NSURL *url = [main URLForResource:@"index" withExtension:@"html" subdirectory:@"welcome"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[_welcomeView loadRequest:request];
}

- (void)configureCell:(JarListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	[cell setDelegate:self];
	
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	NSNumber *count = [product valueForKeyPath:@"purchases.@count"];
    [cell.titleLabel setText:product.title];
	[cell.quantityLabel setText:[count stringValue]];
	[cell setProduct:product];

	if (count.integerValue == 1) {
		
		[cell.eatButton setTitle:NSLocalizedString(@"Eat It", @"Eat It") forState:UIControlStateNormal];
		[cell.exchangeButton setTitle:NSLocalizedString(@"Add to Exchange", @"Add to Exchange") forState:UIControlStateNormal];
		
	} else {
		
		[cell.eatButton setTitle:NSLocalizedString(@"Eat One", @"Eat One") forState:UIControlStateNormal];
		[cell.exchangeButton setTitle:NSLocalizedString(@"Add 1 to Exchange", @"Add 1 to Exchange") forState:UIControlStateNormal];
	}
	
	[cell.exchangeButton setEnabled:_shouldEnableExchangeButtons];

	ImageCachingService *service = [[ImageCachingService alloc] init];
	UIImage *image = [service cachedImageAtPath:product.imagePath];
	if (!image) {
		
		[service setDelegate:self];
		[service beginLoadingImageAtPath:product.imagePath withUserData:indexPath];
		
	} else {
		
		[cell.iconView setImage:image];
	}
}

- (void)reloadVisibleCells {
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[self configureCell:(JarListItemCell *)cell atIndexPath:indexPath];
	}
}

- (void)showHideViews {
	
	int count = [_fetchedResultsController.managedObjectContext countForFetchRequest:_fetchedResultsController.fetchRequest error:nil];
	BOOL shouldShowWelcome = (count == 0);
	float duration = 0.5f;
	
	float welcome = shouldShowWelcome
	? 1.0f
	: 0.0f;
	
	float table = shouldShowWelcome
	? 0.0f
	: 1.0f;
	
	[UIView animateWithDuration:duration animations:^(void) {
		
		[_welcomeView setAlpha:welcome];
		[_tableView setAlpha:table];
	}];
	
	if (!shouldShowWelcome) {
		
		[self fetch];
	}
	
	if ([CandyShopService hasBigCandyJar]) {
	
		[self.navigationItem setRightBarButtonItem:_bigJarDocumentButton];
		[self.navigationItem setTitle:NSLocalizedString(@"Big Candy Jar", @"Big Candy Jar")];
		
	} else {
		
		[self.navigationItem setRightBarButtonItem:nil];
		[self.navigationItem setTitle:NSLocalizedString(@"Candy Jar", @"Candy Jar")];
	}
}

- (void)fetch {
	
	NSError *error = nil;
	[_fetchedResultsController setDelegate:self];
	if (![_fetchedResultsController performFetch:&error]) {
		
		// TODO: handle error
		[_fetchedResultsController setDelegate:nil];
	}
}

- (void)didTapBigJarDocumentButton:(UIBarButtonItem *)sender {
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	Product *product = (Product *)[[repo fetchProductsForProductKind:ProductKindBigCandyJar] lastObject];
	if (!product) return;
	
	
	NSArray *files = [ProductContentService contentFilesWithExtension:@"pdf" forProductIdentifier:product.identifier];
	if (!files || files.count == 0) return;
	
	NSString *fileName = [files lastObject];
	NSString *filePath = [[ProductContentService contentDirectoryForProductIdentifier:product.identifier] stringByAppendingPathComponent:fileName];
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	
	UIDocumentInteractionController *controller = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
	[controller setDelegate:self];
	[controller presentPreviewAnimated:YES];
}


@end

