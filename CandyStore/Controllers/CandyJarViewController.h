//
//  CandyJarViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//


@interface CandyJarViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *welcomeView;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
