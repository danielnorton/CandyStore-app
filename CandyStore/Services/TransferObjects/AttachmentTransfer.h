//
//  AttachmentTransfer.h
// 
//
//  Created by Daniel Norton on 12/10/10.
//


@interface AttachmentTransfer : NSObject

@property (nonatomic, strong) NSURL *localURL;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *parameterName;
@property (nonatomic, strong) NSString *destinationFileName;

@end
