//
//  ProductContentService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/23/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//


@interface ProductContentService : NSObject

+ (NSString *)contentDirectoryForProductIdentifier:(NSString *)identifier;
+ (NSArray *)contentFilesWithExtension:(NSString *)extension forProductIdentifier:(NSString *)identifier;

@end
