//
//  ProductBuilderService.h
//  CandyStore
//
//  Created by Daniel Norton on 7/27/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "AppProductRemoteService.h"


typedef enum {

	ProductBuilderServiceStatusUnknown,
	ProductBuilderServiceStatusRetreivingFromAppService,
	ProductBuilderServiceStatusRetreivingFromAppStore,
	ProductBuilderServiceStatusBuilding,
	ProductBuilderServiceStatusIdle
	
} ProductBuilderServiceStatus;

@class ProductBuilderService;

@protocol ProductBuilderServiceDelegate <NSObject>

- (void)productBuilderService:(ProductBuilderService *)sender didUpdateContext:(NSManagedObjectContext *)context;
- (void)productBuilderServiceDidFail:(ProductBuilderService *)sender;

@end


@interface ProductBuilderService : NSObject <SKProductsRequestDelegate, AppProductRemoteServiceDelegate>

@property (nonatomic, assign) id<ProductBuilderServiceDelegate> delegate;
@property (nonatomic, readonly) ProductBuilderServiceStatus status;
@property (nonatomic, readonly) NSManagedObjectContext *context;

- (void)beginBuildingProducts:(NSManagedObjectContext *)context;

@end
