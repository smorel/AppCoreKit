//
//  CKEditingManager.m
//  CloudKit
//
//  Created by Sebastien Morel on 11-05-05.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKNSNotificationCenter+Edition.h"
#import "CKNSObject+Bindings.h"

NSString* CKEditionPropertyChangedNotification = @"CKEditingManagerPropertyChangedNotification";
NSString* CKEditionObjectAddedNotification = @"CKEditingManagerAddNotification";
NSString* CKEditionObjectRemovedNotification = @"CKEditingManagerRemoveNotification";
NSString* CKEditionObjectReplacedNotification = @"CKEditionObjectReplacedNotification";

NSString* CKEditionObjectsKey = @"CKEditionObjectsKey";
NSString* CKEditionCollectionKey = @"CKEditionCollectionKey";
NSString* CKEditionObjectPropertyKey = @"CKEditionObjectPropertyKey";
NSString* CKEditionIndexesKey = @"CKEditionIndexesKey";
NSString* CKEditionIndexKey = @"CKEditionIndexKey";
NSString* CKEditionReplacedObjectKey = @"CKEditionReplacedObjectKey";
NSString* CKEditionReplacementObjectKey = @"CKEditionReplacementObjectKey";

@implementation NSNotificationCenter (CKEdition)

- (void)notifyPropertyChange:(CKObjectProperty*)property{
	NSMutableDictionary* infos = [NSMutableDictionary dictionary];
	[infos setObject:property forKey:CKEditionObjectPropertyKey];
	[self postNotificationName:CKEditionPropertyChangedNotification object:property.object userInfo:infos];
}

- (void)notifyObjectsAdded:(NSArray*)objects atIndexes:(NSIndexSet *)indexes inCollection:(CKDocumentCollection*)collection{
	NSMutableDictionary* infos = [NSMutableDictionary dictionary];
	[infos setObject:objects forKey:CKEditionObjectsKey];
	[infos setObject:collection forKey:CKEditionCollectionKey];
	[infos setObject:indexes forKey:CKEditionIndexesKey];
	[self postNotificationName:CKEditionObjectAddedNotification object:collection userInfo:infos];
}

- (void)notifyObjectsRemoved:(NSArray*)objects atIndexes:(NSIndexSet *)indexes inCollection:(CKDocumentCollection*)collection{
	NSMutableDictionary* infos = [NSMutableDictionary dictionary];
	[infos setObject:objects forKey:CKEditionObjectsKey];
	[infos setObject:collection forKey:CKEditionCollectionKey];
	[infos setObject:indexes forKey:CKEditionIndexesKey];
	[self postNotificationName:CKEditionObjectRemovedNotification object:collection userInfo:infos];
}

- (void)notifyObjectReplaced:(id)object byObject:(id)other atIndex:(NSInteger)index inCollection:(CKDocumentCollection*)collection{
	NSMutableDictionary* infos = [NSMutableDictionary dictionary];
	[infos setObject:object forKey:CKEditionReplacedObjectKey];
	[infos setObject:other forKey:CKEditionReplacementObjectKey];
	[infos setObject:collection forKey:CKEditionCollectionKey];
	[infos setObject:[NSNumber numberWithInt:index] forKey:CKEditionIndexKey];
	[self postNotificationName:CKEditionObjectReplacedNotification object:collection userInfo:infos];
}

@end

@implementation NSNotification (CKEdition)

- (CKObjectProperty*)objectProperty{
	return (CKObjectProperty*)[[self userInfo] objectForKey:CKEditionObjectPropertyKey];
}

- (NSArray*)objects{
	return (NSArray*)[[self userInfo] objectForKey:CKEditionObjectsKey];
}

- (CKDocumentCollection*)documentCollection{
	return (CKDocumentCollection*)[[self userInfo] objectForKey:CKEditionCollectionKey];
}

- (NSIndexSet*)indexes{
	return (NSIndexSet*)[[self userInfo] objectForKey:CKEditionIndexesKey];
}

- (NSInteger)index{
	return [[[self userInfo] objectForKey:CKEditionIndexKey]intValue];
}

- (id)replacedObject{
	return [[self userInfo] objectForKey:CKEditionReplacedObjectKey];
}

- (id)replacementObject{
	return [[self userInfo] objectForKey:CKEditionReplacementObjectKey];
}

@end