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
	return [self colorFrom255Red:152 green:152 blue:156];
}

+ (UIColor *)lightGrayStoreColor {
	return [self colorFrom255Red:173 green:173 blue:176];
}

+ (UIColor *)shopTableSeperatorColor {
	return [self darkGrayColor];
}

+ (UIColor *)modelTitleTextColor {
	return [self blackColor];
}

+ (UIColor *)modelTitleShadowColor {
	return [self colorFrom255Red:194 green:194 blue:194];
}

+ (UIColor *)subscriptionTitleShadowColor {
	return [self lightGrayStoreColor];
}

+ (UIColor *)buyButtonTextColor {
	return [self whiteColor];
}

+ (UIColor *)buyButtonShadowColor {
	return [self blackColor];
}

+ (UIColor *)buyButtonDisabledTextColor {
	return [self colorFrom255Red:147 green:140 blue:156];
}

+ (UIColor *)buyButtonDisabledShadowColor {
	return [self clearColor];
}

+ (UIColor *)refreshingTitleTextColor {
	return [self darkGrayColor];
}

+ (UIColor *)refreshingTitleShadowColor {
	return [self modelTitleShadowColor];
}

@end
