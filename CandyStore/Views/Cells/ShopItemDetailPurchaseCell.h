//
//  ShopItemDetailPurchaseCell.h
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "BuyButton.h"
#import "Model.h"


@class ShopItemDetailPurchaseCell;

@protocol ShopItemDetailPurchaseCellDelegate <NSObject>

- (void)shopItemDetailPurchaseCell:(ShopItemDetailPurchaseCell *)cell didPresentBuyButtonForProduct:(Product *)product;
- (void)shopItemDetailPurchaseCell:(ShopItemDetailPurchaseCell *)cell didChooseToBuyProduct:(Product *)product;

@end

@interface ShopItemDetailPurchaseCell : UITableViewCell

@property (nonatomic, strong) IBOutlet BuyButton *buyButton;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconView;

@property (nonatomic, weak) Product *product;
@property (nonatomic, weak) id<ShopItemDetailPurchaseCellDelegate> delegate;

- (void)resizeTitleFromBuyButton;


@end

