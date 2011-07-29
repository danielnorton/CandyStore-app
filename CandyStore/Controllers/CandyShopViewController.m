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
#import "CandyStoreAppDelegate.h"
#import "UIApplication+delegate.h"


@interface CandyShopViewController()

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation CandyShopViewController

@synthesize fetchedResultsController;


#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	
	[fetchedResultsController release];
	[super dealloc];
}


#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setFetchedResultsController:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSError *error = nil;
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	NSFetchedResultsController *controller = [repo controllerForAll];
	[controller setDelegate:self];
	[self setFetchedResultsController:controller];
	[repo release];
	
	if (![fetchedResultsController performFetch:&error]) {
		
		// TODO: handle error
		[fetchedResultsController setDelegate:nil];
		[self setFetchedResultsController:nil];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Product *product = (Product *)[fetchedResultsController objectAtIndexPath:indexPath];
	NSString *identifier = [NSString stringWithFormat:@"%d", product.kind];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	id<NSFetchedResultsSectionInfo> info = [fetchedResultsController.sections objectAtIndex:section];
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
    
    UITableView *tableView = self.tableView;
	
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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


#pragma mark -
#pragma mark CandyShopViewController
#pragma mark IBAction
- (IBAction)updateProducts:(id)sender {
	
	CandyStoreAppDelegate *app = [UIApplication thisApp];
	[app updateProducts];
}


#pragma mark Private Extension
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	Product *product = (Product *)[fetchedResultsController objectAtIndexPath:indexPath];
	
	[cell.textLabel setText:product.title];
	[cell.detailTextLabel setText:product.subTitle];
}


@end

