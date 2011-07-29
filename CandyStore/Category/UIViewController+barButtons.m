//
//  UIViewController+barButtons.m
//
//  Created by Daniel Norton on 2/28/11.
//

#import "UIViewController+barButtons.h"

@implementation UIViewController(barButtons)

- (void)setBackButtonTitle:(NSString *)aTitle {

	UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:aTitle
															 style:UIBarButtonItemStylePlain
															target:nil
															action:nil];
	[self.navigationItem setBackBarButtonItem:back];
	[back release];
}

- (void)setBarButtonsEnabled:(BOOL)enabled withToolbar:(UIToolbar *)toolbar withLeftBarButtonItem:(UIBarButtonItem *)left {
	
	if (enabled) {
		
		[self.navigationItem setLeftBarButtonItem:nil];
		
	} else {
		
		[self.navigationItem setLeftBarButtonItem:left];
		[left setEnabled:enabled];
	}
	
	[self.navigationItem.leftBarButtonItem setEnabled:enabled];
	[self.navigationItem.rightBarButtonItem setEnabled:enabled];
	
	[toolbar.items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
	
		UIBarButtonItem *button = (UIBarButtonItem *)obj;
		[button setEnabled:enabled];
	}];
}

@end
