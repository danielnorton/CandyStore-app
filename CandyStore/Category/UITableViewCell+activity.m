//
//  UITableViewCell+activity.m
//
//  Created by Daniel Norton on 2/16/11.
//

#import "UITableViewCell+activity.h"


@implementation UITableViewCell(activity)

- (void)setActivityIndicatorAccessoryView:(UIActivityIndicatorViewStyle)style {
	
	UIActivityIndicatorView *activity = (UIActivityIndicatorView *)self.accessoryView;
	if (![activity isKindOfClass:[UIActivityIndicatorView class]]) {
		
		activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
		[self setAccessoryView:activity];
	}
	
	if (![activity isAnimating]) {
		
		[activity startAnimating];
	}
	
	[activity setHidesWhenStopped:NO];
}

- (void)clearAccessoryViewWith:(UITableViewCellAccessoryType)type {
	
	[self setAccessoryView:nil];
	[self setAccessoryType:type];
}

- (void)setActivityIndicatorAnimating:(BOOL)isAnimating {
	
	UIActivityIndicatorView *activity = (UIActivityIndicatorView *)self.accessoryView;
	if (!activity || ![activity isKindOfClass:[UIActivityIndicatorView class]]) return;
	
	if (isAnimating) {
		
		[activity startAnimating];
		
	} else {
		
		[activity stopAnimating];
	}

}


@end

