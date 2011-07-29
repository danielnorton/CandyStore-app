//
//  RepositoryBase.h
//  
//
//  Created by Daniel Norton on 10/6/10.
//

@interface RepositoryBase : NSObject 


@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSString *typeName;
@property (nonatomic, retain) NSArray *defaultSortDescriptors;
@property (nonatomic, retain) NSString *defaultSectionNameKeyPath;
@property (nonatomic, retain) NSString *keyName;

- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext;
- (NSManagedObject *)itemForId:(id)modelId;
- (NSArray *)fetchAll;
- (NSArray *)fetchForSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate;
- (NSFetchedResultsController *)controllerForAll;
- (NSFetchedResultsController *)controllerWithSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate;
- (NSUInteger)count;
- (NSFetchRequest *)newFetchRequestWithSort:(NSArray *)sortDescriptors andPredicate:(NSPredicate *)predicate;
- (void)undo;
- (void)rollback;
- (BOOL)save:(NSError **)error;
- (BOOL)purge:(NSError **)error;
- (BOOL)deleteAndSave:(NSManagedObject *)object error:(NSError **)error;
- (NSManagedObject *)insertNewObject;
- (void)setDefaultSortDescriptorsByKey:(NSString *)defaultSortKey;
- (void)setDefaultSortDescriptorsByKey:(NSString *)defaultSortKey ascending:(BOOL)ascending;

@end

