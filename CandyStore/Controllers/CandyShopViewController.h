//
//  CandyShopViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RefreshingTableViewController.h"
#import "ImageCachingService.h"
#import "ShopItemCell.h"


@interface CandyShopViewController : RefreshingTableViewController
<ImageCachingServiceDelegate>

@property (nonatomic, retain) IBOutlet ShopItemCell *shopItemCell;

@end

