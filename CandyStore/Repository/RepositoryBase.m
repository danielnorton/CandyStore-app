//
//  RepositoryBase.m
//  
//
//  Created by Daniel Norton on 10/6/10.
//

#import "RepositoryBase.h"


@implementation RepositoryBase

@synthesize managedObjectContext;
@synthesize typeName;
@synthesize defaultSortDescriptors;
@synthesize defaultSectionNameKeyPath;
@synthesize keyName;

#pragma mark -
#pragma mark NSObject
- (void)dealloc {
	[managedObjectContext release];
	[typeName release];
	[defaultSortDescriptors release];
	[defaultSectionNameKeyPath release];
	[keyName release];
	[super dealloc];
}

#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super init]) return nil;
	
	[self setManagedObjectContext:aManagedObjectContext];
	
	return self;
}

- (NSManagedObject *)itemForId:(id)modelId {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",keyName, modelId];
	NSArray *items = [self fetchForSort:self.defaultSortDescriptors andPredicate:pred];
	if (!items || items.count == 0) {
		return nil;
	}
	
	return [items lastObject];
}

- (NSArray *)fetchAll {
	
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:defaultSortDescriptors andPredicate:nil];
	NSArray *all = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (error != nil) {
		return nil;
	}
	
	return all;
}

- (NSArray *)fetchForSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate {
	
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:sortDescriptors andPredicate:predicate];
	NSArray *all = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (error != nil) {
		return nil;
	}
	
	return all;
}

- (NSFetchedResultsController *)controllerForAll {

	NSFetchedResultsController *fetch = [self controllerWithSort:defaultSortDescriptors andPredicate:nil];	
	return fetch;
}

- (NSFetchedResultsController *)controllerWithSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate {
	
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:sortDescriptors andPredicate:predicate];
	
	NSFetchedResultsController *fetchedResultsController =
	[[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										 managedObjectContext:managedObjectContext
										   sectionNameKeyPath:defaultSectionNameKeyPath
													cacheName:nil] autorelease];
	[fetchRequest release];
	return fetchedResultsController;
}

- (NSUInteger)count {
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:nil andPredicate:nil];
	
	NSError *error = nil;
	NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
	if (error != nil) {
		return 0;
	}	
	return count;
}

- (NSFetchRequest *)newFetchRequestWithSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setReturnsDistinctResults:YES];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:typeName
											  inManagedObjectContext:managedObjectContext];	
	
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[fetchRequest setPredicate:predicate];
	
	return fetchRequest;
}

- (void)undo {
	[managedObjectContext undo];
}

- (void)rollback {
	[managedObjectContext rollback];
}

- (BOOL)save:(NSError **)error {
	return [managedObjectContext save:error];
}

- (BOOL)purge:(NSError **)error {
	
	if (*error) return NO;
	
	NSError *internal = nil;
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:nil andPredicate:nil];
	NSArray *all = [managedObjectContext executeFetchRequest:fetchRequest error:&internal];
	[fetchRequest release];
	if (internal) {
		*error = internal;
		return NO;
	}
	
	[all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSManagedObject *one = (NSManagedObject *)obj;
		[managedObjectContext deleteObject:one];
	}];
	
	return [self save:error];
}

- (BOOL)deleteAndSave:(NSManagedObject *)object error:(NSError **)error {
	[managedObjectContext deleteObject:object];
	return [self save:error];
}

- (NSManagedObject *)insertNewObject {
	return [NSEntityDescription insertNewObjectForEntityForName:typeName
										 inManagedObjectContext:managedObjectContext];
}

- (void)setDefaultSortDescriptorsByKey:(NSString *)defaultSortKey {
	[self setDefaultSortDescriptorsByKey:defaultSortKey ascending:YES];
}

- (void)setDefaultSortDescriptorsByKey:(NSString *)defaultSortKey ascending:(BOOL)ascending {
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:defaultSortKey ascending:ascending];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	[self setDefaultSortDescriptors:sortDescriptors];
}


@end

