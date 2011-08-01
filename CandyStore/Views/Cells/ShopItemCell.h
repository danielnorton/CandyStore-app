//
//  ShopItemCell.h
//  CandyStore
//
//  Created by Daniel Norton on 7/29/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "BuyButton.h"


@interface ShopItemCell : UITableViewCell

@property (nonatomic, retain) IBOutlet BuyButton *buyButton;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subTitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;


@end

