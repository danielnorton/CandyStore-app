//
//  UIFont+candy.m
//  CandyStore
//
//  Created by Daniel Norton on 8/2/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "UIFont+candy.h"

@implementation UIFont(candy)

+ (UIFont *)productDescriptionFont {
	return [self systemFontOfSize:16.0f];
}

+ (UIFont *)subscriptionTitleFont {
	return [self systemFontOfSize:16.0f];
}
+ (UIFont *)modelTitleFont {
	return [self boldSystemFontOfSize:20.0f];
}

+ (UIFont *)buyButtonFont {
	return [self boldSystemFontOfSize:15.0f];
}

+ (UIFont *)buyButtonDisabledFont {
	return [self boldSystemFontOfSize:13.0f];
}


@end

