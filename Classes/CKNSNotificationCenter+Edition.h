//
//  CKEditingManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKProperty.h"
#import "CKCollection.h"

/** TODO
 */
extern NSString* CKEditionPropertyChangedNotification;

/** TODO
 */
extern NSString* CKEditionObjectAddedNotification;

/** TODO
 */
extern NSString* CKEditionObjectRemovedNotification;

/** TODO
 */
extern NSString* CKEditionObjectReplacedNotification;


/** TODO
 */
@interface NSNotificationCenter (CKEdition)
- (void)notifyPropertyChange:(CKProperty*)property;
- (void)notifyObjectsAdded:(NSArray*)objects atIndexes:(NSIndexSet *)indexes inCollection:(CKCollection*)collection;
- (void)notifyObjectsRemoved:(NSArray*)objects atIndexes:(NSIndexSet *)indexes inCollection:(CKCollection*)collection;
- (void)notifyObjectReplaced:(id)object byObject:(id)other atIndex:(NSInteger)index inCollection:(CKCollection*)collection;
@end


/** TODO
 */
@interface NSNotification (CKEdition)
- (CKProperty*)objectProperty;
- (NSArray*)objects;
- (CKCollection*)documentCollection;
- (NSIndexSet*)indexes;
- (NSInteger)index;
- (id)replacedObject;
- (id)replacementObject;
@end