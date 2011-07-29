//
//  NSURLRequest+cert.m
//  
//
//  Created by Daniel Norton on 12/7/10.
//

#import "NSURLRequest+cert.h"

@implementation NSURLRequest(cert)

+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host {
	
	return YES;
}

@end
