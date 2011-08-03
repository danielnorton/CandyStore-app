//
//  Purchase+model.m
//  CandyStore
//
//  Created by Daniel Norton on 8/3/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "Purchase+model.h"

@implementation Purchase(model)

- (void)setIsExpired:(BOOL)expired {
	[self setIsExpiredData:[NSNumber numberWithBool:expired]];
}

- (BOOL)isExpired {
	return [self.isExpiredData boolValue];
}

@end
