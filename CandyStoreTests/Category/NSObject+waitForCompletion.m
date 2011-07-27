//
//  NSObject+waitForCompletion.m
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "NSObject+waitForCompletion.h"

@implementation NSObject(waitForCompletion)

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs doneTest:(BOOL(^)())doneTest {
	
	NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
	do {
		
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
		if(timeoutDate.timeIntervalSinceNow < 0.0) break;
		
	} while (!doneTest());
	
	return doneTest();
}


@end

