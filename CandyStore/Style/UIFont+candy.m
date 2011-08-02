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
	return [UIFont systemFontOfSize:16.0f];
}

+ (UIFont *)subscriptionTitleFont {
	return [UIFont systemFontOfSize:16.0f];
}
+ (UIFont *)modelTitleFont {
	return [UIFont boldSystemFontOfSize:20.0f];
}

@end
