//
//  ImageCachingService.h
//
//  Created by Daniel Norton on 3/15/11.
//


@class ImageCachingService;


@protocol ImageCachingServiceDelegate <NSObject>

- (void)ImageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData;

@end


@interface ImageCachingService : NSObject

@property (nonatomic, retain) id<ImageCachingServiceDelegate> delegate;
@property (nonatomic, readonly) BOOL isResponseFromNetworkCache;

+ (void)beginLoadingImageAtPath:(NSString *)path;
+ (void)deleteCacheItemAtPath:(NSString *)path;
+ (void)purge;

- (UIImage *)cachedImageAtPath:(NSString *)path;
- (void)beginLoadingImageAtPath:(NSString *)path withUserData:(id)userData;


@end

