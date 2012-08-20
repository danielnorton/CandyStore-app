//
//  ImageCachingService.m
//
//  Created by Daniel Norton on 3/15/11.
//

#import "ImageCachingService.h"
#import "SelfReferenceService.h"


@interface ImageCachingService()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSString *remotePath;
@property (nonatomic, strong) id callerUserData;
@property (nonatomic, readonly) int httpCode;

- (NSString *)cachePath;
- (NSString *)localImagePath:(NSString *)path;
- (void)saveImage:(UIImage *)image fromPath:(NSString *)path;
- (void)notifyDelegateOfImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData;

@end


@implementation ImageCachingService


@synthesize delegate;
@synthesize isResponseFromNetworkCache;
@synthesize connection;
@synthesize receivedData;
@synthesize remotePath;
@synthesize callerUserData;
@synthesize httpCode;

#pragma mark -
#pragma mark NSURLConnection delegate
- (NSCachedURLResponse *)connection:(NSURLConnection *)aConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	
	isResponseFromNetworkCache = NO;
	return cachedResponse;
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
	
	if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
		httpCode = [(NSHTTPURLResponse *)response statusCode];
	}

	[receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)anError {
	
	NSLog(@"Error loading data: %@", anError);

	[self setConnection:nil];
	[self setReceivedData:nil];
	[SelfReferenceService remove:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	
	if (httpCode != 404) {
		
		float scale = [[UIScreen mainScreen] scale];
		UIImage *temp = [UIImage imageWithData:receivedData];
		UIImage *image = [UIImage imageWithCGImage:[temp CGImage] scale:scale orientation:UIImageOrientationUp];
		
		[self saveImage:image fromPath:remotePath];
		[self notifyDelegateOfImage:image fromPath:remotePath withUserData:callerUserData];
	}
	
	[self setConnection:nil];
	[self setReceivedData:nil];
	[SelfReferenceService remove:self];
}


#pragma mark -
#pragma mark ImageCachingService
+ (void)beginLoadingImageAtPath:(NSString *)path {
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	if (![service cachedImageAtPath:path]) {
		
		[service beginLoadingImageAtPath:path withUserData:nil];
	}
	
}

+ (void)deleteCacheItemAtPath:(NSString *)path {
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	NSString *cachePath = [service localImagePath:path];
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	[mgr removeItemAtPath:cachePath error:nil];
}

+ (void)purge {
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	NSString *cachePath = [service cachePath];
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	NSError *error = nil;
	NSArray *content = [mgr contentsOfDirectoryAtPath:cachePath error:&error];
	if (!error) {

		[content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			
			NSString *fullPath = [cachePath stringByAppendingPathComponent:obj];
			[mgr removeItemAtPath:fullPath error:nil];
		}];
	}

}

- (UIImage *)cachedImageAtPath:(NSString *)path {
	
	NSString *imagePath = [self localImagePath:path];
	UIImage *image = nil;
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	if ([mgr fileExistsAtPath:imagePath]) {
		
		UIImage *unsized = [UIImage imageWithContentsOfFile:imagePath];
		float scale = [[UIScreen mainScreen] scale];
		image = [UIImage imageWithCGImage:unsized.CGImage scale:scale orientation:UIImageOrientationUp];
	}
	
	
	return image;
}

- (void)beginLoadingImageAtPath:(NSString *)path withUserData:(id)userData {
	
	[SelfReferenceService add:self];
	
	isResponseFromNetworkCache = YES;
	
	[self setRemotePath:path];
	[self setCallerUserData:userData];
	
	NSURL *url = [NSURL URLWithString:path];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (aConnection) {
		
		NSMutableData *data = [[NSMutableData alloc] init];
		[self setReceivedData:data];
		[self setConnection:aConnection];
		[connection start];
		
	} else {
		NSLog(@"Error connecting");
	}
}


#pragma Private Extension
- (NSString *)cachePath {

	NSString *library = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
	NSString *path = [library stringByAppendingPathComponent:@"images"];
	
	static BOOL fileExists = NO;
	if (!fileExists) {
		
		NSFileManager *mgr = [[NSFileManager alloc] init];
		NSError *error = nil;
		BOOL success = [mgr createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
		if (success && !error) {
			fileExists = YES;
		}
	}
	
	return path;
}

- (NSString *)localImagePath:(NSString *)path {
	
	NSString *directory = [self cachePath];
	NSString *hash = [NSString stringWithFormat:@"%@.png", [path lastPathComponent]];
	return [directory stringByAppendingPathComponent:hash];
}

- (void)saveImage:(UIImage *)image fromPath:(NSString *)path {
	
	NSString *imagePath = [self localImagePath:path];
	
	NSData *data = UIImagePNGRepresentation(image);
	[data writeToFile:imagePath atomically:YES];
}

- (void)notifyDelegateOfImage:(UIImage *)image fromPath:(NSString *)path withUserData:(id)userData {
	
	if (![delegate conformsToProtocol:@protocol(ImageCachingServiceDelegate)]) return;
	
	[delegate imageCachingService:self didLoadImage:image fromPath:path withUserData:userData];
}


@end

