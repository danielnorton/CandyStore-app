//
//  CandyJarViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "JarListItemCell.h"
#import "ImageCachingService.h"

@interface CandyJarViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate,
NSFetchedResultsControllerDelegate, ImageCachingServiceDelegate,
JarListItemCellDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *welcomeView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet JarListItemCell *jarListItemCell;
@end
