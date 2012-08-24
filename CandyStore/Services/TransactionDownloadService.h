//
//  TransactionDownloadService.h
//  CandyStore
//
//  Created by Daniel Norton on 8/23/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>

extern NSString * const TransactionDownloadServiceKeyTransaction;
extern NSString * const TransactionDownloadServiceKeyDownload;
extern NSString * const TransactionDownloadServiceBeginTransactionDownloads;
extern NSString * const TransactionDownloadServiceCompleteTransactionDownloads;
extern NSString * const TransactionDownloadServiceReportDownloadWaiting;
extern NSString * const TransactionDownloadServiceReportDownloadActive;
extern NSString * const TransactionDownloadServiceReportDownloadPaused;
extern NSString * const TransactionDownloadServiceReportDownloadFinished;
extern NSString * const TransactionDownloadServiceReportDownloadFailed;
extern NSString * const TransactionDownloadServiceReportDownloadCancelled;


@interface TransactionDownloadService : NSObject

- (void)begin:(SKPaymentTransaction *)transaction;

@end
