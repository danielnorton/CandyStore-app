//
//  HTTPMultipartBuilder.h
// 
//
//  Created by Daniel Norton on 12/10/10.
//  Copyright 2010 Bandit Software. All rights reserved.
//

#import "AttachmentTransfer.h"

@interface HTTPMultipartBuilder : NSObject

+ (void)setRequest:(NSMutableURLRequest *)request withParameters:(NSDictionary *)parameters withAttachment:(AttachmentTransfer *)attachment;


@end

