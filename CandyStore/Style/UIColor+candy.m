//
//  UIColor+candy.m
//  CandyStore
//
//  Created by Daniel Norton on 8/1/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "UIColor+candy.h"
#import "UIColor+helpers.h"

@implementation UIColor(candy)

+ (UIColor *)darkGrayStoreColor {
	return [UIColor colorFrom255Red:152 green:152 blue:156];
}

+ (UIColor *)lightGrayStoreColor {
	return [UIColor colorFrom255Red:173 green:173 blue:176];
}

+ (UIColor *)shopTableSeperatorColor {
	return [UIColor darkGrayColor];
}

+ (UIColor *)productTitleShadowColor {
	return [self whiteColor];
}

+ (UIColor *)subscriptionTitleShadowColor {
	return [self lightGrayStoreColor];
}

@end
