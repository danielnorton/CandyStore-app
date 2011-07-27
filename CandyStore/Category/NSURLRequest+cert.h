//
//  NSURLRequest+cert.h
//  
//
//  Created by Daniel Norton on 12/7/10.
//  Copyright 2010 Bandit Software. All rights reserved.
//

// Thanks
// http://www.cocoanetics.com/2009/11/ignoring-certificate-errors-on-nsurlrequest/
@interface NSURLRequest(cert)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
@end
