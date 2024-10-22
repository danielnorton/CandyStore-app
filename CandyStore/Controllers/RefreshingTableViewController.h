//
//  RefreshingTableViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

typedef NS_ENUM(uint, RefreshingTableViewControllerState) {
	
	RefreshingTableViewControllerStateUnknown,
	RefreshingTableViewControllerStateIdle,
	RefreshingTableViewControllerStateRefresing,
	RefreshingTableViewControllerStateFailed
	
};

@interface RefreshingTableViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, assign) RefreshingTableViewControllerState state;
@property (nonatomic, readonly) BOOL shouldShowRefreshingCell;

- (UITableViewCell *)refreshingCellForTableView:(UITableView *)tableView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureRefreshingCell:(UITableViewCell *)cell;
- (void)beginRefreshing;
- (void)completeRefreshing;
- (void)enableWithLoadingCellMessage:(NSString *)message;
- (void)enableWithLoadingCellMessage:(NSString *)message withAccessory:(UITableViewCellAccessoryType)accessory;
- (void)reloadVisibleCells;
- (void)presentDataError:(NSString *)message;
- (void)resetFetchedResultsController;

@end
