//
//  UIViewController+barButtons.h
//
//  Created by Daniel Norton on 2/28/11.
//


@interface UIViewController(barButtons)

- (void)setBackButtonTitle:(NSString *)aTitle;
- (void)setBarButtonsEnabled:(BOOL)enabled withToolbar:(UIToolbar *)toolbar withLeftBarButtonItem:(UIBarButtonItem *)left;

@end
