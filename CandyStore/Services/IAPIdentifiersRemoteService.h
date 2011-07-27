//
//  IAPIdentifiersRemoteService.h
//  CandyStore
//
//  Created by Daniel Norton on 7/26/11.
//  Copyright 2011 Daniel Norton. All rights reserved.
//

@class IAPIdentifiersRemoteService;

@protocol IAPIdentifiersRemoteServiceDelegate <NSObject>

- (void)identifierRemoteService:(IAPIdentifiersRemoteService *)sender didCompleteRetreiveIdentifiers:(NSArray *)identifiers;

@end


@interface IAPIdentifiersRemoteService : NSObject

@property (nonatomic, assign) id<IAPIdentifiersRemoteServiceDelegate> delegate;

- (void)beginRetreiveIdentifiers;

@end
