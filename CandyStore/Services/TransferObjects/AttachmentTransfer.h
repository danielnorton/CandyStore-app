//
//  AttachmentTransfer.h
// 
//
//  Created by Daniel Norton on 12/10/10.
//  Copyright 2010 Bandit Software. All rights reserved.
//


@interface AttachmentTransfer : NSObject {

	NSURL *localURL;
	NSString *contentType;
	NSString *parameterName;
	NSString *destinationFileName;
}

@property (nonatomic, retain) NSURL *localURL;
@property (nonatomic, retain) NSString *contentType;
@property (nonatomic, retain) NSString *parameterName;
@property (nonatomic, retain) NSString *destinationFileName;

@end
