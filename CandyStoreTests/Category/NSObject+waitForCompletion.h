//
//  NSObject+waitForCompletion.h
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//


@interface NSObject(waitForCompletion)

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs doneTest:(BOOL(^)())doneTest;

@end
