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

@end


@implementation ModelCore

@synthesize managedObjectContext = _managedObjectContext;

#pragma mark -
#pragma mark NSObject
- (id)init {
	if (![super init]) return nil;
	
	_useBundleFile = kUseBundleFile;
	
	NSString *name = [[UIApplication appName] stringByReplacingOccurrencesOfString:@" " withString:[NSString string]];
	[self setFileName:name];
	return self;
}

#pragma mark -
#pragma mark ModelCore
- (NSManagedObjectContext *) managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
	
	if (!_useBundleFile) {
		[_managedObjectContext save:nil];
	}
	
    return _managedObjectContext;
}

#pragma mark Private Extension
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
	NSString *type = @"sqlite";
	NSString *fileNameWithExtension = [NSString stringWithFormat:@"%@.%@", _fileName, type];
	NSString *storePath = [[self applicationLibraryDirectory] stringByAppendingPathComponent: fileNameWithExtension];
	NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
	
	NSLog(@"path: %@", storePath);
	if (_useBundleFile) {
		// Set up the store, provide a pre-populated default store.
		NSString *bundleStorePath = [[NSBundle mainBundle] pathForResource:_fileName ofType:type];
		NSFileManager *fileManager = [[NSFileManager alloc] init];
		if (![fileManager fileExistsAtPath:storePath]) {
			if (bundleStorePath) {
				[fileManager copyItemAtPath:bundleStorePath toPath:storePath error:NULL];
			}
		}
	}
	
	NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
							 NSInferMappingModelAutomaticallyOption: @YES};
	
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
	NSError *error;
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
    return _persistentStoreCoordinator;
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
