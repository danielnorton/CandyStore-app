//
//  ModelCore.h
//  
//
//  Created by Daniel Norton on 4/28/10.
//


@interface ModelCore : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

+ (ModelCore *)sharedManager;

@end

