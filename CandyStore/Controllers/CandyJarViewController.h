//
//  CandyJarViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "JarListItemCell.h"
#import "ImageCachingService.h"
#import "ExchangeAddCreditRemoteService.h"


@interface CandyJarViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate,
NSFetchedResultsControllerDelegate, UIDocumentInteractionControllerDelegate,
ImageCachingServiceDelegate, JarListItemCellDelegate, ExchangeAddCreditRemoteServiceDelegate>


@property (nonatomic, strong) IBOutlet UIWebView *welcomeView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet JarListItemCell *jarListItemCell;

- (void)resetShouldEnableExchangeButtons;


@end

