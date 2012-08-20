//
//  RepositoryBase.h
//  
//
//  Created by Daniel Norton on 10/6/10.
//

@interface RepositoryBase : NSObject 


@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSArray *defaultSortDescriptors;
@property (nonatomic, strong) NSString *defaultSectionNameKeyPath;
@property (nonatomic, strong) NSString *keyName;

- (id)initWithContext:(NSManagedObjectContext *)aManagedObjectContext;
- (NSManagedObject *)itemForId:(id)modelId;
- (NSManagedObject *)getOrAddItemForId:(id)modelId;
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

