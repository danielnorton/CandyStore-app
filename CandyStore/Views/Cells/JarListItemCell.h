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

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;
@property (nonatomic, retain) IBOutlet UIButton *eatButton;
@property (nonatomic, retain) IBOutlet UIButton *exchangeButton;

@property (nonatomic, assign) Product *product;

@property (nonatomic, assign) id<JarListItemCellDelegate> delegate;

@end
