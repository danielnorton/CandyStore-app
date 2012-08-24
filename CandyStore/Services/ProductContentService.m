//
//  ProductContentService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/23/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//

#import "ProductContentService.h"

@implementation ProductContentService

#pragma mark -
#pragma mark TransactionDownloadService
+ (NSString *)contentDirectoryForProductIdentifier:(NSString *)identifier {
	
	NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return [docs stringByAppendingPathComponent:identifier];
}

+ (NSArray *)contentFilesWithExtension:(NSString *)extension forProductIdentifier:(NSString *)identifier {
	
	NSString *lextension = [extension lowercaseString];
	NSString *contentDirectory = [ProductContentService contentDirectoryForProductIdentifier:identifier];
	NSFileManager *mgr = [[NSFileManager alloc] init];
	
	BOOL isDir;
	if (![mgr fileExistsAtPath:contentDirectory isDirectory:&isDir] || !isDir) return nil;
	
	NSError *lsError = nil;
	NSArray *files = [mgr contentsOfDirectoryAtPath:contentDirectory error:&lsError];
	if (lsError) return nil;
	
	return [files filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		
		NSString *file = (NSString *)evaluatedObject;
		NSString *lfileExt = [[file pathExtension] lowercaseString];
		return [lfileExt isEqualToString:lextension];
	}]];
}

@end
