//
//  CKFeedViewControllerFactory.h
//  FeedView
//
//  Created by Sebastien Morel on 11-03-18.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CKObjectViewControllerFactory : NSObject {
	NSMutableDictionary* _mappings;
	NSMutableDictionary* _styles;
	id _objectController;
}

@property (nonatomic, retain) id mappings;
@property (nonatomic, retain) id styles;
@property (nonatomic, assign) id objectController;

+ (CKObjectViewControllerFactory*)factoryWithMappings:(NSDictionary*)mappings withStyles:(NSDictionary*)styles;
+ (id)factoryWithMappings:(NSDictionary*)mappings withStyles:(NSDictionary*)styles withFactoryClass:(Class)type;

- (Class)controllerClassForIndexPath:(NSIndexPath*)indexPath;
- (id)styleForIndexPath:(NSIndexPath*)indexPath;
- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath;

@end
