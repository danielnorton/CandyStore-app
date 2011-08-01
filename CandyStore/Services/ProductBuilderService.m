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
#import "ImageCachingService.h"
#import "EndpointService.h"


#define kKeyBigCandyJar @"bigcandyjar"
#define kKeyExchange @"exchange"
#define kKeyCandy @"candy"


@interface ProductBuilderService()

- (void)setContext:(NSManagedObjectContext *)context;
- (void)setStatus:(ProductBuilderServiceStatus)status;
- (void)beginAppStoreProducts:(NSSet *)identifiers;
- (ProductKind)productKindFromServerKey:(NSString *)key;
- (NSString *)priceFromProduct:(SKProduct *)product;
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
	
	[request release];
}


#pragma mark SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

	[self setStatus:ProductBuilderServiceStatusBuilding];
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:context];
	[response.invalidProductIdentifiers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSString *invalidIdentifier = (NSString *)obj;
		id product = [repo itemForId:invalidIdentifier];
		[context deleteObject:product];
	}];
	
	[response.products enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		SKProduct *skProduct = (SKProduct *)obj;
		Product *product = (Product *)[repo itemForId:skProduct.productIdentifier];
		
		NSString *localizedPrice = [self priceFromProduct:skProduct];
		[product setTitle:skProduct.localizedTitle];
		
		if (product.parent) {
			
			[product setPrice:skProduct.price];
			[product setLocalizedPrice:localizedPrice];
			
			[product.parent setTitle:skProduct.localizedTitle];
			[product.parent setProductDescription:skProduct.localizedDescription];
			[product.parent setPrice:nil];
			[product.parent setLocalizedPrice:nil];
			
		} else {
		
			[product setProductDescription:skProduct.localizedDescription];			
			[product setPrice:skProduct.price];
			[product setLocalizedPrice:localizedPrice];
		}
	}];
	
	
	NSError *error = nil;
	BOOL save = [repo save:&error];
	[repo release];
	
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
}

- (void)remoteServiceDidTimeout:(RemoteServiceBase *)sender {
	
	[self notifyDelegateDidFail];
}


#pragma mark AppProductRemoteServiceDelegate
- (void)appProductRemoteService:(AppProductRemoteService *)sender didCompleteRetreiveProducts:(NSArray *)theProducts {
	
	[self setStatus:ProductBuilderServiceStatusBuilding];
	
	ProductRepository *repo = [[ProductRepository alloc] initWithContext:context];
	
	NSError *error = nil;
	[ImageCachingService purge];
	BOOL purged = [repo purge:&error];
	if (!purged || error) {
		
		[context rollback];
		[self notifyDelegateDidFail];
		
	} else {
	
		NSMutableSet *identifiers = [[NSMutableSet alloc] initWithCapacity:0];
		
		[theProducts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			
			NSDictionary *item = (NSDictionary *)obj;
			
			NSString *imageKey = [UIScreen mainScreen].scale == 2.0f
			? @"retina_image"
			: @"image";
			NSString *imagePath = [EndpointService serviceFullPathForRelativePath:[item objectForKey:imageKey]];
			
			[ImageCachingService beginLoadingImageAtPath:imagePath];
			
			ProductKind kind = [self productKindFromServerKey:[item objectForKey:@"key"]];
			
			id productIdentifier = [item objectForKey:@"identifier"];
			
			Product *newProduct = (Product *)[repo insertNewObject];
			[newProduct setImagePath:imagePath];
			[newProduct setKind:kind];
			[newProduct setIdentifier:productIdentifier];
			
			NSDictionary *durations = (NSDictionary *)[item objectForKey:@"durations"];
			if (durations) {
				
				[durations enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
					
					[identifiers addObject:key];
					
					Product *subscription = [repo addSubscriptionToProduct:newProduct];
					[subscription setImagePath:imagePath];
					[subscription setKind:kind];
					[subscription setIdentifier:key];
					[subscription setProductDescription:obj];
				}];
				
			} else {
				
				[identifiers addObject:productIdentifier];
			}
		}];
		
		error = nil;
		BOOL save = [repo save:&error];
		if (!save || error) {
			
			[context rollback];
			[self notifyDelegateDidFail];
			
		} else {
			
			[self beginAppStoreProducts:identifiers];
		}
		
		[identifiers release];
	}
	
	[repo release];
}

- (void)appProductRemoteServiceDidFailRetreiveProducts:(AppProductRemoteService *)sender {
	
	[self notifyDelegateDidFail];
}


#pragma mark -
#pragma mark ProductBuilderService
- (void)beginBuildingProducts:(NSManagedObjectContext *)aContext {

	[self setStatus:ProductBuilderServiceStatusRetreivingFromAppService];
	
	[self setContext:aContext];
	
	AppProductRemoteService *service = [[AppProductRemoteService alloc] init];
	[service setDelegate:self];
	[service beginRetreiveProducts];
	[service release];
}


#pragma mark Private Extension
- (void)setContext:(NSManagedObjectContext *)aContext {
	
	if ([context isEqual:aContext]) return;
	[aContext retain];
	[context release];
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
	
	if ([key isEqualToString:kKeyBigCandyJar]) {
		return ProductKindBigCandyJar;
	}
	
	if ([key isEqualToString:kKeyExchange]) {
		return ProductKindExchange;
	}
	
	if ([key isEqualToString:kKeyCandy]) {
		return ProductKindCandy;
	}
	
	return ProductKindUnknown;
}

- (NSString *)priceFromProduct:(SKProduct *)product {
	
	[currencyFormatter setLocale:product.priceLocale];
	return [currencyFormatter stringFromNumber:product.price];
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
