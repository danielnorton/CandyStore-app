//
//  UITableViewDelgate+emptyFooter.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "UITableViewDelgate+emptyFooter.h"

@implementation UIViewController(emptyFooter)

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	if (section != (tableView.numberOfSections - 1)) return nil;
	
	UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
	return view;
}

@end
