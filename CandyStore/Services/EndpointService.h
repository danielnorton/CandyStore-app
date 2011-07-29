//
//  EndpointService.h
//
//  Created by Daniel Norton on 2/16/11.
//



@interface EndpointService : NSObject

+ (NSString *)serviceFullPathForRelativePath:(NSString *)relativePath;
+ (NSString *)appProductsPath;

@end

