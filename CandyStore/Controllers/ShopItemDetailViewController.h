//
//  ShopItemDetailViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "Model.h"
#import "ShopItemDetailPurchaseCell.h"
#import "ImageCachingService.h"

@interface ShopItemDetailViewController : UITableViewController
<ImageCachingServiceDelegate, ShopItemDetailPurchaseCellDelegate, SKProductsRequestDelegate>

@property (nonatomic, weak) Product *product;

@end
