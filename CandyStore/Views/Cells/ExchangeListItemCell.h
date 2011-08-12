//
//  ExchangeListItemCell.h
//  CandyStore
//
//  Created by Daniel Norton on 8/11/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//


@interface ExchangeListItemCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *quantityLabel;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;

+ (float)defaultHeight;

@end
