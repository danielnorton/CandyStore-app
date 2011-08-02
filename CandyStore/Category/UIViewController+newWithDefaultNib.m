//
//  UIViewController+newWithDefaultNib.m
// 
//
//  Created by Daniel Norton on 11/3/10.
//

#import "UIViewController+newWithDefaultNib.h"

@implementation UIViewController(newWithDefaultNib)

+ (id)newWithDefaultNib {
	Class type = [self class];
	NSString *name = NSStringFromClass(type);
	return [[type alloc] initWithNibName:name bundle:nil];
}

@end
