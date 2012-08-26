//
//  CandyExchangeViewController.h
//  CandyStore
//
//  Created by Daniel Norton on 7/25/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "RefreshingTableViewController.h"
#import "ImageCachingService.h"
#import "ExchangeUseCreditRemoteService.h"


@interface CandyExchangeViewController : RefreshingTableViewController
<ImageCachingServiceDelegate, ExchangeUseCreditRemoteServiceDelegate>


@end
