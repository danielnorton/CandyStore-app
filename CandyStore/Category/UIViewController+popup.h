//
//  UIViewController+popup.h
// 
//
//  Created by Daniel Norton on 10/19/10.
//  Copyright 2011 Firefly Logic. All rights reserved.
//


@interface UIViewController(popup)
- (void)popup:(NSString *)message;
- (void)popup:(NSString *)message withDelegate:(id<UIAlertViewDelegate>)delegate;
@end
