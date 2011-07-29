//
//  ImageLoadingService.m
//
//  Created by Daniel Norton on 3/15/11.
//

#import "ImageCachingService.h"
#import "Reachability.h"


@interface ImageCachingService()

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSString *remotePath;
@property (nonatomic, retain) id callerUserData;
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
#pragma mark NSObject
- (void)dealloc {
	
	[delegate release];
	[connection release];
	[receivedData release];
	[remotePath release];
	[callerUserData release];
	[super dealloc];
}


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
	[self release];
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
	[self release];
}


#pragma mark -
#pragma mark ImageLoadingService
+ (void)beginLoadingImageAtPath:(NSString *)path {
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	if (![service cachedImageAtPath:path]) {
		
		[service beginLoadingImageAtPath:path withUserData:nil];
	}
	
	[service release];
}

+ (void)deleteCacheItemAtPath:(NSString *)path {
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	NSString *cachePath = [service localImagePath:path];
	[service release];
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	[mgr removeItemAtPath:cachePath error:nil];
	[mgr release];
}

+ (void)purge {
	
	ImageCachingService *service = [[ImageCachingService alloc] init];
	NSString *cachePath = [service cachePath];
	[service release];
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	NSError *error = nil;
	NSArray *content = [mgr contentsOfDirectoryAtPath:cachePath error:&error];
	if (!error) {

		[content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			
			NSString *fullPath = [cachePath stringByAppendingPathComponent:obj];
			[mgr removeItemAtPath:fullPath error:nil];
		}];
	}

	[mgr release];
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
	
	[mgr release];
	
	return image;
}

- (void)beginLoadingImageAtPath:(NSString *)path withUserData:(id)userData {
	
	Reachability *reach = [Reachability reachabilityForInternetConnection];
	if ([reach currentReachabilityStatus] == NotReachable) {
		return;
	}

	[self retain];
	
	isResponseFromNetworkCache = YES;
	
	[self setRemotePath:path];
	[self setCallerUserData:userData];
	
	NSURL *url = [NSURL URLWithString:path];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	NSURLConnection *aConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	if (aConnection) {
		
		NSMutableData *data = [[NSMutableData alloc] init];
		[self setReceivedData:data];
		[data release];
		[self setConnection:aConnection];
		[aConnection release];
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
		[mgr release];
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
	
	[delegate ImageCachingService:self didLoadImage:image fromPath:path withUserData:userData];
}


@end

