//
//  JarListItemCell.h
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "Model.h"


@class JarListItemCell;

@protocol JarListItemCellDelegate <NSObject>

- (void)jarListItemCell:(JarListItemCell *)cell didEatOneProduct:(Product *)product;
- (void)jarListItemCell:(JarListItemCell *)cell didExchangeOneProduct:(Product *)product;

@end

@interface JarListItemCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *quantityLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconView;
@property (nonatomic, strong) IBOutlet UIButton *eatButton;
@property (nonatomic, strong) IBOutlet UIButton *exchangeButton;

@property (nonatomic, weak) Product *product;

@property (nonatomic, weak) id<JarListItemCellDelegate> delegate;

@end
