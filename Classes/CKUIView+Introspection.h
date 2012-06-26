//
//  CKUIView+Introspection.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-06-09.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 */
@interface UIView (CKIntrospectionAdditions)

- (void)insertSubviewsObjects:(NSArray *)views atIndexes:(NSIndexSet*)indexes;
- (void)removeSubviewsObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)removeAllSubviewsObjects;

@end