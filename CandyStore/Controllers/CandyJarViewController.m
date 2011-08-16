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
#import "AboutViewController.h"
#import "UIViewController+newWithDefaultNib.h"


@interface CandyJarViewController()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) BOOL shouldEnableExchangeButtons;

- (void)loadWelcomeView;
- (void)configureCell:(JarListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadVisibleCells;
- (void)showHideViews;
- (void)fetch;

@end


@implementation CandyJarViewController

@synthesize welcomeView;
@synthesize tableView;
@synthesize jarListItemCell;
@synthesize fetchedResultsController;
@synthesize shouldEnableExchangeButtons;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[welcomeView release];
	[tableView release];
	[jarListItemCell release];
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
	
	[tableView setSeparatorColor:[UIColor shopTableSeperatorColor]];
	
	[welcomeView setAlpha:0.0f];
	[welcomeView setOpaque:NO];
	[tableView setAlpha:0.0f];
	
	[self loadWelcomeView];
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForMyCandyJar];
	[repo release];
	[self setFetchedResultsController:controller];
	[self fetch];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
		
	[self.navigationController setNavigationBarHidden:YES];
	
	[self showHideViews];
	
	[self resetShouldEnableExchangeButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	id<NSFetchedResultsSectionInfo> info = [fetchedResultsController.sections objectAtIndex:section];
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(JarListItemCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
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
	[service release];
}

- (void)jarListItemCell:(JarListItemCell *)cell didExchangeOneProduct:(Product *)product {

}


#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	[self passFailedAuthenticationNotificationToAppDelegate:sender];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	[self passTimeoutNotificationToAppDelegate:sender];
}


#pragma mark -
#pragma mark CandyJarViewController
- (void)resetShouldEnableExchangeButtons {
	
	BOOL newEnable = [CandyShopService canAddToExchangeCredits];
	if (newEnable != shouldEnableExchangeButtons) {
		
		[self setShouldEnableExchangeButtons:newEnable];
		[self.tableView reloadData];
	}
}


#pragma mark IBAction
- (IBAction)didTapAboutButton:(id)sender {

	AboutViewController *about = [AboutViewController newWithDefaultNib];
	[about setModalTransitionStyle:UIModalTransitionStylePartialCurl];
	[self presentModalViewController:about animated:YES];
	[about release];
}


#pragma mark Private Extension
- (void)loadWelcomeView {
	
	NSBundle *main = [NSBundle mainBundle];
	NSURL *url = [main URLForResource:@"index" withExtension:@"html" subdirectory:@"welcome"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[welcomeView loadRequest:request];
}

- (void)configureCell:(JarListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	[cell setDelegate:self];
	
	Product *product = (Product *)[fetchedResultsController objectAtIndexPath:indexPath];
	
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
	
	[cell.exchangeButton setEnabled:shouldEnableExchangeButtons];

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

- (void)reloadVisibleCells {
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[self configureCell:(JarListItemCell *)cell atIndexPath:indexPath];
	}
}

- (void)showHideViews {
	
	int count = [fetchedResultsController.managedObjectContext countForFetchRequest:fetchedResultsController.fetchRequest error:nil];
	BOOL shouldShowWelcome = (count == 0);
	float duration = 0.5f;
	
	float welcome = shouldShowWelcome
	? 1.0f
	: 0.0f;
	
	float table = shouldShowWelcome
	? 0.0f
	: 1.0f;
	
	[UIView animateWithDuration:duration animations:^(void) {
		
		[welcomeView setAlpha:welcome];
		[tableView setAlpha:table];
	}];
	
	if (!shouldShowWelcome) {
		
		[self fetch];
	}
}

- (void)fetch {
	
	NSError *error = nil;
	[fetchedResultsController setDelegate:self];
	if (![fetchedResultsController performFetch:&error]) {
		
		[fetchedResultsController setDelegate:nil];
	}
}


@end

