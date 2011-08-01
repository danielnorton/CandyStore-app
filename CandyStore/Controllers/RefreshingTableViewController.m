//
//  RefreshingTableViewController.m
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RefreshingTableViewController.h"
#import "UIViewController+barButtons.h"
#import "UITableViewCell+activity.h"


@implementation RefreshingTableViewController

@synthesize fetchedResultsController;
@synthesize state;

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


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([self shouldShowRefreshingCell]) return 1;
		
	return fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([self shouldShowRefreshingCell]) return 1;
	
	id<NSFetchedResultsSectionInfo> info = [fetchedResultsController.sections objectAtIndex:section];
	return [info numberOfObjects];
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
#pragma mark RefreshingTableViewController
#pragma mark Properties
- (void)setState:(RefreshingTableViewControllerState)aState {
	
	state = aState;
	NSLog(@"state: %d", state);
}


#pragma mark Public Messages
- (BOOL)shouldShowRefreshingCell {
	
	return (state == RefreshingTableViewControllerStateRefresing)
	|| (state == RefreshingTableViewControllerStateFailed);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// no-op: leave it to inheritor
}

- (void)configureRefreshingCell:(UITableViewCell *)cell {
	
	[cell.textLabel setFont:[UIFont systemFontOfSize:17.0f]];
	[cell.textLabel setText:NSLocalizedString(@"Refreshing...", @"Refreshing...")];
	[cell.textLabel setTextColor:[UIColor lightGrayColor]];
	[cell.textLabel setShadowColor:[UIColor blackColor]];
	[cell.textLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
	[cell setActivityIndicatorAccessoryView:UIActivityIndicatorViewStyleGray];
}

- (void)beginRefreshing {
	
	[self.view setUserInteractionEnabled:NO];
	
	[self setState:RefreshingTableViewControllerStateRefresing];
	[self setBarButtonsEnabled:NO withToolbar:nil withLeftBarButtonItem:nil];
	
	UITableView *tableView = self.tableView;
	
	NSArray *sections = [fetchedResultsController sections];
	int count = (sections.count == 0)
	? 0
	: sections.count - 1;
	
	[fetchedResultsController setDelegate:nil];
	[tableView beginUpdates];
	
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:sections.count];
	NSIndexSet *removeSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, count)];
	
	for (int i = 0; i < sections.count; i++) {
		
		id<NSFetchedResultsSectionInfo> section = [sections objectAtIndex:i];
		int j = (i == 0) ? 1 : 0;
		for (; j < [section numberOfObjects]; j++) {
			
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
			[indexPaths addObject:indexPath];
		}		
	}
	
	[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
	[tableView deleteSections:removeSections withRowAnimation:UITableViewRowAnimationFade];
	
	NSIndexSet *top = [NSIndexSet indexSetWithIndex:0];
	[tableView reloadSections:top withRowAnimation:UITableViewRowAnimationNone];
	
	[tableView endUpdates];
}

- (void)completeRefreshing {
	
	[self.view setUserInteractionEnabled:YES];
	
	NSError *error = nil;
	[fetchedResultsController performFetch:&error];
	if (error) {
		
		[self setState:RefreshingTableViewControllerStateFailed];
		[self enableWithLoadingCellMessage:NSLocalizedString(@"Refresh Failed", @"Refresh Failed")];
		return;
	}
	
	[self setState:RefreshingTableViewControllerStateIdle];
	
	UITableView *tableView = self.tableView;
	
	NSArray *sections = [fetchedResultsController sections];
	[fetchedResultsController setDelegate:self];
	[tableView beginUpdates];
	
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:sections.count];
	NSIndexSet *removeSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, sections.count - 1)];
	
	for (int i = 0; i < sections.count; i++) {
		
		id<NSFetchedResultsSectionInfo> section = [sections objectAtIndex:i];
		int j = (i == 0) ? 1 : 0;
		for (; j < [section numberOfObjects]; j++) {
			
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
			[indexPaths addObject:indexPath];
		}		
	}
	
	[tableView insertSections:removeSections withRowAnimation:UITableViewRowAnimationFade];
	[tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
	
	NSIndexSet *top = [NSIndexSet indexSetWithIndex:0];
	[tableView reloadSections:top withRowAnimation:UITableViewRowAnimationNone];
	
	[self.tableView endUpdates];
	
	[self setBarButtonsEnabled:YES withToolbar:nil withLeftBarButtonItem:nil];
}

- (void)enableWithLoadingCellMessage:(NSString *)message {
	
	[self.view setUserInteractionEnabled:YES];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	[cell.textLabel setText:message];
	[self setBarButtonsEnabled:YES withToolbar:nil withLeftBarButtonItem:nil];
}

- (void)reloadVisibleCells {
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[self configureCell:cell atIndexPath:indexPath];
	}
}


@end
