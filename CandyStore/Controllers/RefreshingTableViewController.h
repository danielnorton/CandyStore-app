//
//  RefreshingTableViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

typedef enum {
	
	RefreshingTableViewControllerStateUnknown,
	RefreshingTableViewControllerStateIdle,
	RefreshingTableViewControllerStateRefresing,
	RefreshingTableViewControllerStateFailed
	
} RefreshingTableViewControllerState;

@interface RefreshingTableViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) RefreshingTableViewControllerState state;
@property (nonatomic, readonly) BOOL shouldShowRefreshingCell;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureRefreshingCell:(UITableViewCell *)cell;
- (void)beginRefreshing;
- (void)completeRefreshing;
- (void)enableWithLoadingCellMessage:(NSString *)message;
- (void)enableWithLoadingCellMessage:(NSString *)message withAccessory:(UITableViewCellAccessoryType)accessory;
- (void)reloadVisibleCells;

@end
