//
//  UITableViewCell+activity.h
//
//  Created by Daniel Norton on 2/16/11.
//


@interface UITableViewCell(activity)

- (void)setActivityIndicatorAccessoryView:(UIActivityIndicatorViewStyle)style;
- (void)clearAccessoryViewWith:(UITableViewCellAccessoryType)type;
- (void)setActivityIndicatorAnimating:(BOOL)isAnimating;
@end
