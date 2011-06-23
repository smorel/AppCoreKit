//
//  CKEditingManager.h
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKObjectProperty.h"

extern NSString* CKEditionPropertyChangedNotification;
extern NSString* CKEditionObjectAddedNotification;
extern NSString* CKEditionObjectRemovedNotification;
extern NSString* CKEditionObjectReplacedNotification;

@interface NSNotificationCenter (CKEdition)
- (void)notifyPropertyChange:(CKObjectProperty*)property;
- (void)notifyObjectsAdded:(NSArray*)objects atIndexes:(NSIndexSet *)indexes inCollection:(CKDocumentCollection*)collection;
- (void)notifyObjectsRemoved:(NSArray*)objects atIndexes:(NSIndexSet *)indexes inCollection:(CKDocumentCollection*)collection;
- (void)notifyObjectReplaced:(id)object byObject:(id)other atIndex:(NSInteger)index inCollection:(CKDocumentCollection*)collection;
@end

@interface NSNotification (CKEdition)
- (CKObjectProperty*)objectProperty;
- (NSArray*)objects;
- (CKDocumentCollection*)documentCollection;
- (NSIndexSet*)indexes;
- (NSInteger)index;
- (id)replacedObject;
- (id)replacementObject;
@end