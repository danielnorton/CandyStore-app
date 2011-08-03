//
//  EndpointService.m
//
//  Created by Daniel Norton on 2/16/11.
//

#import "EndpointService.h"


#define kWebServerRoot @"http://daniels-lappy.local:3000/"
#define kWebServerProductsPath @"/products"
#define kWebServerReceiptVerificationPath @"/verifyReceipt"

@implementation EndpointService


#pragma mark -
#pragma mark EndpointService
#pragma mark Public Messages
+ (NSString *)serviceFullPathForRelativePath:(NSString *)relativePath {
	return [kWebServerRoot stringByAppendingPathComponent:relativePath];
}

+ (NSString *)appProductsPath {
	return [self serviceFullPathForRelativePath:kWebServerProductsPath];
}

+ (NSString *)receiptVerificationPath {
	return [self serviceFullPathForRelativePath:kWebServerReceiptVerificationPath];
}


@end

