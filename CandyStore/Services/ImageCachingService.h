//
//  ImageCachingService.h
//
//  Created by Daniel Norton on 3/15/11.
//


@class ImageCachingService;


@protocol ImageCachingServiceDelegate <NSObject>

- (void)imageCachingService:(ImageCachingService *)sender didLoadImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData;

@end


@interface ImageCachingService : NSObject

@property (nonatomic, assign) id<ImageCachingServiceDelegate> delegate;
@property (nonatomic, readonly) BOOL isResponseFromNetworkCache;

+ (void)beginLoadingImageAtPath:(NSString *)path;
+ (void)deleteCacheItemAtPath:(NSString *)path;
+ (void)purge;

- (UIImage *)cachedImageAtPath:(NSString *)path;
- (void)beginLoadingImageAtPath:(NSString *)path withUserData:(id)userData;


@end

