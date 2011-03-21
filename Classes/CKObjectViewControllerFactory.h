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
	id _objectController;
}

@property (nonatomic, retain) id mappings;
@property (nonatomic, assign) id objectController;

+ (CKObjectViewControllerFactory*)factoryWithMappings:(NSDictionary*)mappings;

- (Class)controllerClassForIndexPath:(NSIndexPath*)indexPath;
- (void)initializeController:(id)controller atIndexPath:(NSIndexPath*)indexPath;

@end
