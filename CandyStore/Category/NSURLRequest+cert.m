//
//  NSURLRequest+cert.m
//  
//
//  Created by Daniel Norton on 12/7/10.
//  Copyright 2010 Bandit Software. All rights reserved.
//

#import "NSURLRequest+cert.h"

@implementation NSURLRequest(cert)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host {
	
	return YES;
}

@end
