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
#import "Style.h"


@implementation RefreshingTableViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewDidUnload {
	[super viewDidUnload];
	
	[self setFetchedResultsController:nil];
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


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([self shouldShowRefreshingCell]) return 1;
		
	return _fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([self shouldShowRefreshingCell]) return 1;
	
	id<NSFetchedResultsSectionInfo> info = (_fetchedResultsController.sections)[section];
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
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


#pragma mark -
#pragma mark RefreshingTableViewController
#pragma mark Public Messages
- (BOOL)shouldShowRefreshingCell {
	
	return (_state == RefreshingTableViewControllerStateRefresing)
	|| (_state == RefreshingTableViewControllerStateFailed);
}

- (UITableViewCell *)refreshingCellForTableView:(UITableView *)tableView {
	
	static NSString *refreshingCellIdentifier = @"refreshingCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:refreshingCellIdentifier];
	if (!cell) {
		
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:refreshingCellIdentifier];
	}
	
	[self configureRefreshingCell:cell];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	// no-op: leave it to inheritor
}

- (void)configureRefreshingCell:(UITableViewCell *)cell {
	
	[cell.textLabel setFont:[UIFont modelTitleFont]];
	[cell.textLabel setText:NSLocalizedString(@"Refreshing...", @"Refreshing...")];
	[cell.textLabel setTextColor:[UIColor refreshingTitleTextColor]];
	[cell.textLabel setShadowColor:[UIColor refreshingTitleShadowColor]];
	[cell.textLabel setShadowOffset:CGSizeMake(0.0f, 1.0f)];
	[cell setActivityIndicatorAccessoryView:UIActivityIndicatorViewStyleGray];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell.textLabel setMinimumScaleFactor:0.5f];
	[cell.textLabel setAdjustsFontSizeToFitWidth:YES];
	[cell.textLabel setLineBreakMode:NSLineBreakByClipping];
}

- (void)beginRefreshing {
	
	[self.view setUserInteractionEnabled:NO];
	
	[self setState:RefreshingTableViewControllerStateRefresing];
	[self setBarButtonsEnabled:NO withToolbar:nil];
	
	UITableView *tableView = self.tableView;
	[_fetchedResultsController setDelegate:nil];
	
	int sectionCount = [tableView numberOfSections];
	
	[tableView beginUpdates];
	
	NSIndexSet *top = [NSIndexSet indexSetWithIndex:0];
	
	if (sectionCount == 0) {
		
		[tableView insertSections:top withRowAnimation:UITableViewRowAnimationFade];
		
		NSArray *refreshRows = @[[NSIndexPath indexPathForRow:0 inSection:0]];
		[tableView insertRowsAtIndexPaths:refreshRows withRowAnimation:UITableViewRowAnimationFade];
		
	} else {
		
		int count = sectionCount - 1;
		NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:0];
		NSIndexSet *removeSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, count)];
		
		for (int i = 0; i < sectionCount; i++) {
			
			int j = (i == 0) ? 1 : 0;
			for (; j < [tableView numberOfRowsInSection:i]; j++) {
				
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
				[indexPaths addObject:indexPath];
			}
		}
		
		[tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
		[tableView deleteSections:removeSections withRowAnimation:UITableViewRowAnimationFade];
		[tableView reloadSections:top withRowAnimation:UITableViewRowAnimationNone];
	}

	[tableView endUpdates];
}

- (void)completeRefreshing {
	
	[self.view setUserInteractionEnabled:YES];
	
	NSError *error = nil;
	[_fetchedResultsController performFetch:&error];
	if (error) {
		
		[self setState:RefreshingTableViewControllerStateFailed];
		[self enableWithLoadingCellMessage:NSLocalizedString(@"Refresh Failed", @"Refresh Failed")];
		return;
	}
	
	[self setState:RefreshingTableViewControllerStateIdle];
	
	UITableView *tableView = self.tableView;
	
	NSArray *sections = [_fetchedResultsController sections];
	[_fetchedResultsController setDelegate:self];
	[tableView beginUpdates];
	
	NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:sections.count];
	NSIndexSet *removeSections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, sections.count - 1)];
	
	for (int i = 0; i < sections.count; i++) {
		
		id<NSFetchedResultsSectionInfo> section = sections[i];
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
	
	[self setBarButtonsEnabled:YES withToolbar:nil];
}

- (void)enableWithLoadingCellMessage:(NSString *)message {

	[self enableWithLoadingCellMessage:message withAccessory:UITableViewCellAccessoryNone];
}

- (void)enableWithLoadingCellMessage:(NSString *)message withAccessory:(UITableViewCellAccessoryType)accessory {
	
	[self.view setUserInteractionEnabled:YES];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	[cell.textLabel setText:message];
	[cell clearAccessoryViewWith:accessory];
	[self setBarButtonsEnabled:YES withToolbar:nil];
}

- (void)reloadVisibleCells {
	
	NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
	for (NSIndexPath *indexPath in visiblePaths) {
		UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
		[self configureCell:cell atIndexPath:indexPath];
	}
}

- (void)presentDataError:(NSString *)message {
	
	[self enableWithLoadingCellMessage:message];
	[self resetFetchedResultsController];
}

- (void)resetFetchedResultsController {
	// inheritor should implement
}


@end
