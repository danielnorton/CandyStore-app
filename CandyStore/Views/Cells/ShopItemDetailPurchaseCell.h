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

@property (nonatomic, retain) IBOutlet BuyButton *buyButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;

@property (nonatomic, assign) Product *product;
@property (nonatomic, assign) id<ShopItemDetailPurchaseCellDelegate> delegate;


@end

