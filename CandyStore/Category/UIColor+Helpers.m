//
//  UIColor+helpers.m
//
//  Created by Daniel Norton on 6/23/10.
//

#import "UIColor+Helpers.h"


@implementation UIColor(helpers)

static float max = 255.0f;

+(UIColor *)colorFrom255Red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue {
	return [UIColor colorFrom255Red:red green:green blue:blue alpha:max];
}

+(UIColor *)colorFrom255Red:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue alpha:(NSInteger)alpha {
	
	return [UIColor colorWithRed:red/max green:green/max blue:blue/max alpha:alpha/max];
}


@end

