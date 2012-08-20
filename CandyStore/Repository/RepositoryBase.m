//
//  RepositoryBase.m
//  
//
//  Created by Daniel Norton on 10/6/10.
//

#import "RepositoryBase.h"


@implementation RepositoryBase


#pragma mark -
#pragma mark RepositoryBase
- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext {
	if (![super init]) return nil;
	
	[self setManagedObjectContext:aManagedObjectContext];
	[self setDefaultSectionNameKeyPath:nil];
	
	NSString *className = NSStringFromClass([self class]);
	NSString *typeConvention = [className stringByReplacingOccurrencesOfString:@"Repository" withString:[NSString string]];
	[self setTypeName:typeConvention];
	
	return self;
}

- (NSManagedObject *)itemForId:(id)modelId {
	
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"%K == %@",_keyName, modelId];
	NSArray *items = [self fetchForSort:self.defaultSortDescriptors andPredicate:pred];
	if (!items || items.count == 0) {
		return nil;
	}
	
	return [items lastObject];
}

- (NSManagedObject *)getOrAddItemForId:(id)modelId {
	
	NSManagedObject *object = [self itemForId:modelId];
	if (!object) {
		object = [self insertNewObject];
		[object setValue:modelId forKey:_keyName];
	}
	
	return object;
}

- (NSArray *)fetchAll {
	
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:_defaultSortDescriptors andPredicate:nil];
	NSArray *all = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error != nil) {
		return nil;
	}
	
	return all;
}

- (NSArray *)fetchForSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate {
	
	NSError *error = nil;
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:sortDescriptors andPredicate:predicate];
	NSArray *all = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
	if (error != nil) {
		return nil;
	}
	
	return all;
}

- (NSFetchedResultsController *)controllerForAll {
	
	NSFetchedResultsController *fetch = [self controllerWithSort:_defaultSortDescriptors andPredicate:nil];
	return fetch;
}

- (NSFetchedResultsController *)controllerWithSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate {
	
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:sortDescriptors andPredicate:predicate];
	
	NSFetchedResultsController *fetchedResultsController =
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
										 managedObjectContext:_managedObjectContext
										   sectionNameKeyPath:_defaultSectionNameKeyPath
													cacheName:nil];
	return fetchedResultsController;
}

- (NSUInteger)count {
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:nil andPredicate:nil];
	
	NSError *error = nil;
	NSUInteger count = [_managedObjectContext countForFetchRequest:fetchRequest error:&error];
	if (error != nil) {
		return 0;
	}	
	return count;
}

- (NSFetchRequest *)newFetchRequestWithSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setReturnsDistinctResults:YES];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:_typeName
											  inManagedObjectContext:_managedObjectContext];
	
	[fetchRequest setReturnsDistinctResults:YES];
	[fetchRequest setEntity:entity];
	[fetchRequest setSortDescriptors:sortDescriptors];
	[fetchRequest setPredicate:predicate];
	
	return fetchRequest;
}

- (void)undo {
	[_managedObjectContext undo];
}

- (void)rollback {
	[_managedObjectContext rollback];
}

- (BOOL)save:(NSError **)error {
	return [_managedObjectContext save:error];
}

- (BOOL)purge:(NSError **)error {
	
	if (error) return NO;
	
	NSError *internal = nil;
	NSFetchRequest *fetchRequest = [self newFetchRequestWithSort:nil andPredicate:nil];
	NSArray *all = [_managedObjectContext executeFetchRequest:fetchRequest error:&internal];
	if (internal) {
		*error = internal;
		return NO;
	}
	
	[all enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		NSManagedObject *one = (NSManagedObject *)obj;
		[_managedObjectContext deleteObject:one];
	}];
	
	return [self save:error];
}

- (BOOL)deleteAndSave:(NSManagedObject *)object error:(NSError **)error {
	[_managedObjectContext deleteObject:object];
	return [self save:error];
}

- (NSManagedObject *)insertNewObject {
	return [NSEntityDescription insertNewObjectForEntityForName:_typeName
										 inManagedObjectContext:_managedObjectContext];
}

- (void)setDefaultSortDescriptorsByKey:(NSString *)defaultSortKey {
	[self setDefaultSortDescriptorsByKey:defaultSortKey ascending:YES];
}

- (void)setDefaultSortDescriptorsByKey:(NSString *)defaultSortKey ascending:(BOOL)ascending {
	
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:defaultSortKey ascending:ascending];
	NSArray *sortDescriptors = @[sortDescriptor];
	[self setDefaultSortDescriptors:sortDescriptors];
}


@end

