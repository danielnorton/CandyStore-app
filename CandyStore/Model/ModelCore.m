//
//  ModelCore.m
// 
//
//  Created by Daniel Norton on 10/6/10.
//

#import "ModelCore.h"
#import "UIApplication+delegate.h"

#define kUseBundleFile NO


@interface ModelCore()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) BOOL useBundleFile;
@property (nonatomic, strong) NSString *fileName;

- (NSString *)applicationLibraryDirectory;

@end

@implementation ModelCore


@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;
@synthesize useBundleFile;
@synthesize fileName;

#pragma mark -
#pragma mark NSObject
- (id)init {
	if (![super init]) return nil;
	
	useBundleFile = kUseBundleFile;
	
	NSString *name = [[UIApplication appName] stringByReplacingOccurrencesOfString:@" " withString:[NSString string]];
	[self setFileName:name];
	return self;
}

#pragma mark -
#pragma mark ModelCore
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
	
	if (!useBundleFile) {
		[managedObjectContext save:nil];
	}
	
    return managedObjectContext;
}

#pragma mark Private Extensions
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
	NSString *type = @"sqlite";
	NSString *fileNameWithExtension = [NSString stringWithFormat:@"%@.%@", fileName, type];
	NSString *storePath = [[self applicationLibraryDirectory] stringByAppendingPathComponent: fileNameWithExtension];
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSLog(@"path: %@", storePath);
	if (useBundleFile) {	
		// Set up the store, provide a pre-populated default store.
		NSString *bundleStorePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		if (![fileManager fileExistsAtPath:storePath]) {
			if (bundleStorePath) {
				[fileManager copyItemAtPath:bundleStorePath toPath:storePath error:NULL];
			}
		}
	}
	
	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
							 NSInferMappingModelAutomaticallyOption: @YES};
	
	persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	NSError *error;
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
    return persistentStoreCoordinator;
}

- (NSString *)applicationLibraryDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Singleton
static ModelCore *sharedModelManager = nil;

+(ModelCore *)sharedManager {
    if (sharedModelManager == nil) {
        sharedModelManager = [[super allocWithZone:NULL] init];
    }
    return sharedModelManager;
}

+(id)allocWithZone:(NSZone *)zone {
    return [self sharedManager];
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}


@end
