//
//  ProductBuilderService.m
//  CandyStore
//
//  Created by Daniel Norton on 7/27/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

#import "ProductBuilderService.h"
#import "Model.h"
#import "ProductRepository.h"
#import "PurchaseRepository.h"
#import "ImageCachingService.h"
#import "EndpointService.h"
#import "NSObject+remoteErrorToApp.h"
#import "CandyShopService.h"
#import "FakeStoreKitBuilderService.h"


#define kProductBuilderServiceLastUpdate @"ProductBuilderServiceLastUpdate"
#define kProductBuilderServiceLastUpdateInterval -120.0


@interface ProductBuilderService()

- (void)setContext:(NSManagedObjectContext *)context;
- (void)setStatus:(ProductBuilderServiceStatus)status;
- (void)beginAppStoreProducts:(NSSet *)identifiers;
- (ProductKind)productKindFromServerKey:(NSString *)key;
- (NSString *)priceFromProduct:(SKProduct *)product;
- (void)linkOrphanedPurchases;
- (void)buildFakeStoreKitProducts;
- (void)notifyDelegateDidUpdate;
- (void)notifyDelegateDidFail;

@end

@implementation ProductBuilderService

NSNumberFormatter *currencyFormatter;

@synthesize delegate;
@synthesize status;
@synthesize context;

#pragma mark -
#pragma mark NSObject
+ (void)initialize {

	currencyFormatter = [[NSNumberFormatter alloc] init];
	[currencyFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
}


#pragma mark SKRequestDelegate
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	
	[self notifyDelegateDidFail];
}

- (void)requestDidFinish:(SKRequest *)request {
	
}


#pragma mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

	[self setStatus:ProductBuilderServiceStatusBuilding];
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:context];
	[response.invalidProductIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSString *invalidIdentifier = (NSString *)obj;
		Product *product = (Product *)[repo itemForId:invalidIdentifier];
		[product setIsActive:NO];
	}];
	
	[response.products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		SKProduct *skProduct = (SKProduct *)obj;
		Product *product = (Product *)[repo itemForId:skProduct.productIdentifier];
		
		NSString *localizedPrice = [self priceFromProduct:skProduct];
		[product setLocalizedPrice:localizedPrice];
		[product setTitle:skProduct.localizedTitle];
		
		if (product.parent) {
			
			[product.parent setTitle:skProduct.localizedTitle];
			[product.parent setProductDescription:skProduct.localizedDescription];
			[product.parent setLocalizedPrice:nil];
			
		} else {
			
			[product setProductDescription:skProduct.localizedDescription];
		}
	}];
	
	[self linkOrphanedPurchases];
	
	NSError *error = nil;
	BOOL save = [repo save:&error];
	
	if (!save || error) {
		
		[context rollback];
		[self notifyDelegateDidFail];
		return;
	}
	
	[self notifyDelegateDidUpdate];
}


#pragma mark RemoteServiceDelegate
- (void)remoteServiceDidFailAuthentication:(RemoteServiceBase *)sender {
	
	[self notifyDelegateDidFail];
	[self passFailedAuthenticationNotificationToAppDelegate:sender];
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	
	[self notifyDelegateDidFail];
	[self passTimeoutNotificationToAppDelegate:sender];
}


#pragma mark AppProductRemoteServiceDelegate
- (void)appProductRemoteService:(AppProductRemoteService *)sender didCompleteRetreiveProducts:(NSArray *)theProducts {
	
	[self setStatus:ProductBuilderServiceStatusBuilding];
	
	[ImageCachingService purge];
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:context];
	[repo setAllProductsInactive];
	
	NSMutableSet *identifiers = [[NSMutableSet alloc] initWithCapacity:0];
	
	[theProducts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSDictionary *item = (NSDictionary *)obj;
		
		NSString *imageKey = [UIScreen mainScreen].scale == 2.0f
		? @"retina_image"
		: @"image";
		NSString *imagePath = [EndpointService serviceFullPathForRelativePath:item[imageKey]];
		
		[ImageCachingService beginLoadingImageAtPath:imagePath];
		
		ProductKind kind = [self productKindFromServerKey:item[@"key"]];
		
		id productIdentifier = item[@"identifier"];
		
		Product *product = [repo addOrRetreiveProductFromIdentifer:productIdentifier];
		[product setImagePath:imagePath];
		[product setKind:kind];
		[product setIndex:[NSNumber numberWithInteger:idx]];
		[product setIsActive:YES];
		[product setInternalKey:item[@"key"]];
		
		NSDictionary *durations = (NSDictionary *)item[@"durations"];
		if (durations) {
			
			__block int subscriptionIndex = 0;
			[durations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
				
				[identifiers addObject:key];
				
				Product *subscription = [repo addOrUpdateSubscriptionFromIdentifer:key toProduct:product];
				[subscription setImagePath:imagePath];
				[subscription setKind:kind];
				[subscription setProductDescription:obj];
				[subscription setIndex:@(subscriptionIndex)];
				subscriptionIndex++;
				[subscription setIsActive:YES];
			}];
			
		} else {
			
			[identifiers addObject:productIdentifier];
		}
	}];
	
	NSError *error = nil;
	BOOL save = [repo save:&error];
	if (!save || error) {
		
		[context rollback];
		[self notifyDelegateDidFail];
		
	} else {
		
		if ([CandyShopService isStoreKitEnabled]) {
			
			[self beginAppStoreProducts:identifiers];
			
		} else {
			
			[self buildFakeStoreKitProducts];
		}
	}
}

- (void)appProductRemoteServiceDidFailRetreiveProducts:(AppProductRemoteService *)sender {
	
	[self notifyDelegateDidFail];
}


#pragma mark -
#pragma mark ProductBuilderService
#pragma mark Class Messages
+ (BOOL)hasSignificantTimePassedSinceLastUpdate {
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:[ModelCore sharedManager].managedObjectContext];
	int count = [repo count];
	if (count == 0) {
		
		return YES;
	}
	
	NSDate *lastUpdate = [[NSUserDefaults standardUserDefaults] objectForKey:kProductBuilderServiceLastUpdate];
	NSTimeInterval elapsed = [lastUpdate timeIntervalSinceNow];
	return (elapsed <= kProductBuilderServiceLastUpdateInterval);
}


#pragma mark Instance Messages
- (void)beginBuildingProducts:(NSManagedObjectContext *)aContext {

	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kProductBuilderServiceLastUpdate];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self setStatus:ProductBuilderServiceStatusRetreivingFromAppService];
	[self setContext:aContext];
	
	AppProductRemoteService *service = [[AppProductRemoteService alloc] init];
	[service setDelegate:self];
	[service beginRetreiveProducts];
}


#pragma mark Private Extension
- (void)setContext:(NSManagedObjectContext *)aContext {
	
	if ([context isEqual:aContext]) return;
	context = aContext;
}

- (void)setStatus:(ProductBuilderServiceStatus)aStatus {
	
	status = aStatus;
	NSLog(@"ProductBuilderService status: %d", status);
}

- (void)beginAppStoreProducts:(NSSet *)identifiers {
	
	[self setStatus:ProductBuilderServiceStatusRetreivingFromAppStore];
	
	SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
	[request setDelegate:self];
	[request start];
}

- (ProductKind)productKindFromServerKey:(NSString *)key {
	
	if ([key isEqualToString:InternalKeyBigCandyJar]) {
		return ProductKindBigCandyJar;
	}
	
	if ([key isEqualToString:InternalKeyExchange]) {
		return ProductKindExchange;
	}
	
	if ([key isEqualToString:InternalKeyCandy]) {
		return ProductKindCandy;
	}
	
	return ProductKindUnknown;
}

- (NSString *)priceFromProduct:(SKProduct *)product {
	
	[currencyFormatter setLocale:product.priceLocale];
	return [currencyFormatter stringFromNumber:product.price];
}

- (void)linkOrphanedPurchases {
	
	// Happens when transactions are dequeued by TransactionReceiptService before
	// products are downloaded in this service.
	
	PurchaseRepository *purchaseRepo = [[PurchaseRepository alloc] initWithContext:context];
	ProductRepository *productRepo = [[ProductRepository alloc] initWithContext:context];
	
	NSArray *orphans = [purchaseRepo fetchOrphanedPurchases];
	[orphans enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		Purchase *purchase = (Purchase *)obj;
		Product *product = [productRepo addOrRetreiveProductFromIdentifer:purchase.productIdentifier];
		[purchaseRepo addOrRetreivePurchaseForProduct:product withTransactionIdentifier:purchase.transactionIdentifier];
	}];
	
}

- (void)buildFakeStoreKitProducts {
	
	
	FakeStoreKitBuilderService *service = [[FakeStoreKitBuilderService alloc] init];
	[service buildFakesForContext:context];
	
	[self notifyDelegateDidUpdate];
}

- (void)notifyDelegateDidUpdate {

	[self setStatus:ProductBuilderServiceStatusIdle];
	
	if (![delegate conformsToProtocol:@protocol(ProductBuilderServiceDelegate)]) return;
	[delegate productBuilderServiceDidUpdate:self];
}

- (void)notifyDelegateDidFail {

	[self setStatus:ProductBuilderServiceStatusFailed];
	
	if (![delegate conformsToProtocol:@protocol(ProductBuilderServiceDelegate)]) return;
	[delegate productBuilderServiceDidFail:self];
}


@end
