//
//  TransactionDownloadService.m
//  CandyStore
//
//  Created by Daniel Norton on 8/23/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//

#import "TransactionDownloadService.h"
#import "Model.h"
#import "ProductContentService.h"


NSString * const TransactionDownloadServiceKeyTransaction = @"TransactionDownloadServiceKeyTransaction";
NSString * const TransactionDownloadServiceKeyDownload = @"TransactionDownloadServiceKeyDownload";
NSString * const TransactionDownloadServiceBeginTransactionDownloads = @"TransactionDownloadServiceBeginTransactionDownloads";
NSString * const TransactionDownloadServiceCompleteTransactionDownloads = @"TransactionDownloadServiceCompleteTransactionDownloads";
NSString * const TransactionDownloadServiceReportDownloadWaiting = @"TransactionDownloadServiceReportDownloadWaiting";
NSString * const TransactionDownloadServiceReportDownloadActive = @"TransactionDownloadServiceReportDownloadActive";
NSString * const TransactionDownloadServiceReportDownloadPaused = @"TransactionDownloadServiceReportDownloadPaused";
NSString * const TransactionDownloadServiceReportDownloadFinished = @"TransactionDownloadServiceReportDownloadFinished";
NSString * const TransactionDownloadServiceReportDownloadFailed = @"TransactionDownloadServiceReportDownloadFailed";
NSString * const TransactionDownloadServiceReportDownloadCancelled = @"TransactionDownloadServiceReportDownloadCancelled";


@interface TransactionDownloadService()

@property (nonatomic, strong) NSMutableArray *downloadProgressTimers;

@end


@implementation TransactionDownloadService


#pragma mark -
#pragma mark NSObject
- (id)init {

	self = [super init];
	if (self) {
		
		[self setDownloadProgressTimers:[NSMutableArray arrayWithCapacity:0]];
	}
	return self;
}


#pragma mark -
#pragma mark TransactionDownloadService
- (void)begin:(SKPaymentTransaction *)transaction {

	NSLog(@"Beginning %i download(s) for %@", transaction.downloads.count, transaction.payment.productIdentifier);
	
	NSArray *notFinished = [transaction.downloads filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
		
		SKDownload *download = (SKDownload *)evaluatedObject;
		return download.downloadState != SKDownloadStateFinished;
		
	}]];
	
	if (notFinished.count == 0) {
		
		[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
		[self notifyName:TransactionDownloadServiceCompleteTransactionDownloads forTransaction:transaction];
		return;
	}
	
	[_downloadProgressTimers makeObjectsPerformSelector:@selector(invalidate)];
	[self setDownloadProgressTimers:nil];
	
	if (transaction.downloads.count == 0) return;
	
	[self notifyName:TransactionDownloadServiceKeyTransaction forTransaction:transaction];
	
	NSMutableArray *newTimers = [NSMutableArray arrayWithCapacity:0];
	[self setDownloadProgressTimers:newTimers];
	
	[transaction.downloads enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		SKDownload *download = (SKDownload *)obj;
		
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.33f
														  target:self
														selector:@selector(tickDownloadTimer:)
														userInfo:download
														 repeats:YES];
		[newTimers addObject:timer];
	}];
	
	[[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
}


#pragma mark Private Messages
- (void)notifyName:(NSString *)name forTransaction:(SKPaymentTransaction *)transaction {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	NSDictionary *dict = @{TransactionDownloadServiceKeyTransaction: transaction};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self
													  userInfo:dict];
}

- (void)notifyName:(NSString *)name forDownload:(SKDownload *)download showingNetworkActivity:(BOOL)show {
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:show];
	
	NSDictionary *dict = @{TransactionDownloadServiceKeyDownload: download};
	
	[[NSNotificationCenter defaultCenter] postNotificationName:name
														object:self
													  userInfo:dict];
}

- (void)tickDownloadTimer:(NSTimer *)timer {
	
	if (![timer.userInfo isKindOfClass:[SKDownload class]]) return;
	
	SKDownload *download = (SKDownload *)timer.userInfo;
	
	if (!download.transaction) {
		
		NSLog(@"found a download without a transaction. Abandoning download of: %@", download.contentIdentifier);
		return;
	}
	
	NSString *message = nil;
	BOOL shouldFinish = NO;
	BOOL showNetwork = YES;
	switch (download.downloadState) {
			
		case SKDownloadStateWaiting:
			message = TransactionDownloadServiceReportDownloadWaiting;
			break;
			
		case SKDownloadStateActive:
			message = TransactionDownloadServiceReportDownloadActive;
			break;
			
		case SKDownloadStatePaused:
			message = TransactionDownloadServiceReportDownloadPaused;
			break;
			
		case SKDownloadStateFinished:
			message = TransactionDownloadServiceReportDownloadFinished;
			shouldFinish = YES;
			break;
			
		case SKDownloadStateFailed:
			message = TransactionDownloadServiceReportDownloadFailed;
			break;
			
		case SKDownloadStateCancelled:
			message = TransactionDownloadServiceReportDownloadCancelled;
			break;
	}
	
	NSLog(@"( %1.3f%% ) %@ == %@", (download.progress * 100), download.transaction.payment.productIdentifier, message);
	
	if (shouldFinish) {
		
		[timer invalidate];
		[_downloadProgressTimers removeObject:timer];
		
		[self saveDownload:download];
		
		if (_downloadProgressTimers.count == 0) {
			
			NSLog(@"Finished all downloads for %@", download.transaction.payment.productIdentifier);
			
			[[SKPaymentQueue defaultQueue] finishTransaction:download.transaction];
			[self notifyName:TransactionDownloadServiceCompleteTransactionDownloads forTransaction:download.transaction];
		}
		
	} else {
		
		[self notifyName:message forDownload:download showingNetworkActivity:showNetwork];
	}
}

- (void)saveDownload:(SKDownload *)download {
	
	if (download.downloadState != SKDownloadStateFinished) return;
	
	[NSThread sleepForTimeInterval:0.33f];
	
	[self saveDownloadContentFromPath:download.contentURL.path
				 forProductIdentifier:download.transaction.payment.productIdentifier];
}

- (BOOL)saveDownloadContentFromPath:(NSString *)path forProductIdentifier:(NSString *)identifier {
	
	NSString *contentPath = [path stringByAppendingPathComponent:@"Contents"];
	NSFileManager *mgr = [[NSFileManager alloc] init];
	
	NSLog(@"Saving content from %@", path);
	
	NSError *lsError = nil;
	NSArray *files = [mgr contentsOfDirectoryAtPath:contentPath error:&lsError];
	if (lsError) {
		
		NSLog(@"Error reading downloaded file: %@\nreason: %@", lsError.localizedDescription, lsError.localizedFailureReason);
		return NO;
	}
	
	NSString *identifierPath = [ProductContentService contentDirectoryForProductIdentifier:identifierPath];
	if (![mgr createDirectoryAtPath:identifierPath withIntermediateDirectories:YES attributes:nil error:nil]) return NO;
	
	static NSString *infoPlist = @"ContentInfo.plist";
	NSString *sourceInfoPath = [path stringByAppendingPathComponent:infoPlist];
	NSString *destinationInfoPath = [identifierPath stringByAppendingPathComponent:infoPlist];
	if ([mgr fileExistsAtPath:destinationInfoPath]) {
		
		if (![mgr removeItemAtPath:destinationInfoPath error:nil]) return NO;
	}
	
	if (![mgr copyItemAtPath:sourceInfoPath toPath:destinationInfoPath error:nil]) return NO;
	
	NSLog(@"Saved local copy of '%@'", destinationInfoPath);
	
	__block BOOL success = YES;
	[files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			
		NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
		NSString *identifierPath = [docs stringByAppendingPathComponent:identifier];
		if (![mgr createDirectoryAtPath:identifierPath withIntermediateDirectories:YES attributes:nil error:nil]) {
			
			*stop = YES;
			success = NO;
			return;
		}
		
		NSString *fileName = (NSString *)obj;
		NSString *sourceFilePath = [contentPath stringByAppendingPathComponent:fileName];
		NSString *destinationFilePath = [identifierPath stringByAppendingPathComponent:fileName];
		
		if ([mgr fileExistsAtPath:destinationFilePath]) {
			
			if (![mgr removeItemAtPath:destinationFilePath error:nil]) {
				
				*stop = YES;
				success = NO;
				return;
			}
		}
		
		if (![mgr copyItemAtPath:sourceFilePath toPath:destinationFilePath error:nil]) {
			
			*stop = YES;
			success = NO;
			return;
		}
		
		NSLog(@"Saved local copy of '%@'", destinationFilePath);
	}];
	
	return success;
}


@end





