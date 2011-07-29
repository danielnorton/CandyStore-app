//
//  EndpointService.m
//
//  Created by Daniel Norton on 2/16/11.
//

#import "EndpointService.h"


#define kWebServerRoot @"http://daniels-lappy.local:3000/"


@implementation EndpointService


#pragma mark -
#pragma mark EndpointService
#pragma mark Public Messages
+ (NSString *)appProductsPath {
	
	return [NSString stringWithFormat:@"%@%@", kWebServerRoot, @"products"];
}


@end

