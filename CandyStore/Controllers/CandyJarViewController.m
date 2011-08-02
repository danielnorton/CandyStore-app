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


#define kWelcomeViewTag -9999

@interface CandyJarViewController()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)loadWelcomeView;
- (void)configureCell:(JarListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)reloadVisibleCells;

@end


@implementation CandyJarViewController

@synthesize welcomeView;
@synthesize tableView;
@synthesize jarListItemCell;
@synthesize fetchedResultsController;

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
	
	[self.view addSubview:tableView];
	[self loadWelcomeView];
	
	NSError *error = nil;
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForMyCandyJar];
	[controller setDelegate:self];
	[repo release];
	
	[self setFetchedResultsController:controller];
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
	[tableView setHidden:!hasSome];
	
	if (wasHidden) {
		
		[tableView reloadData];
	}
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
    }
	
	[self configureCell:cell atIndexPath:indexPath];
	
    return cell;
}


#pragma mark UITableViewDelegate
- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 115.0f;
}


#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	[UIView animateWithDuration:0.33f animations:^(void) {
		
		[welcomeView setAlpha:1.0f];
	}];
}


#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
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
	
	// TODO:
}

- (void)jarListItemCell:(JarListItemCell *)cell didExchangeOneProduct:(Product *)product {

	// TODO:
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

- (void)configureCell:(JarListItemCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	Product *product = (Product *)[self.fetchedResultsController objectAtIndexPath:indexPath];
	
	NSNumber *count = [product valueForKeyPath:@"purchases.@count"];
    [cell.titleLabel setText:product.title];
	[cell.quantityLabel setText:[count stringValue]];

	if (count.integerValue == 1) {
		
		[cell.eatButton setTitle:NSLocalizedString(@"Eat It", @"Eat It") forState:UIControlStateNormal];
		[cell.exchangeButton setTitle:NSLocalizedString(@"Add to Exchange", @"Add to Exchange") forState:UIControlStateNormal];
		
	} else {
		
		[cell.eatButton setTitle:NSLocalizedString(@"Eat One", @"Eat One") forState:UIControlStateNormal];
		[cell.exchangeButton setTitle:NSLocalizedString(@"Add 1 to Exchange", @"Add 1 to Exchange") forState:UIControlStateNormal];
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

- (void)reloadVisibleCells {
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[self configureCell:(JarListItemCell *)cell atIndexPath:indexPath];
	}
}


@end

