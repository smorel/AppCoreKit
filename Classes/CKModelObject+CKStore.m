//
//  CKNSObject+CKStore.m
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject+CKStore.h"

#import "CKStoreDataSource.h"
#import "CKItem.h"
#import "CKStore.h"
#import "CKAttribute.h"
#import "CKDomain.h"
#import "CKDebug.h"
#import "CKModelObject.h"
#import "CKObjectProperty.h"
#import "CKNSValueTransformer+Additions.h"
#import "CKNSStringAdditions.h"
#import "CKWeakRef.h"

NSMutableDictionary* CKModelObjectManager = nil;

@interface CKModelObject (CKStoreAdditionPrivate)
- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain alreadySaved:(NSMutableSet*)alreadySaved;
@end

@implementation CKModelObject (CKStoreAddition)

- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain{
	NSMutableSet* alreadySaved = [NSMutableSet set];
	return [self attributesDictionaryForDomainNamed:domain alreadySaved:alreadySaved];
}

- (void)deleteFromDomainNamed:(NSString*)domain{
	NSAssert(!_loading, @"cannot delete an object while loading it !");
	
	CKItem* item = [CKModelObject itemWithObject:self inDomainNamed:domain];
	if(item){
		CKStore* store = [CKStore storeWithDomainName:domain];
		[store deleteItems:[NSArray arrayWithObject:item]];
	}
}

+ (CKItem *)createItemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain  alreadySaved:(NSMutableSet*)alreadySaved{
	CKStore* store = [CKStore storeWithDomainName:domain];
	BOOL created;
	CKItem *item = [store fetchItemWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (domain == %@)", object.modelName, domain]
								createIfNotFound:YES wasCreated:&created];
	if (created) {
		item.name = object.modelName;
		item.domain = store.domain;
		[store.domain addItemsObject:item];
	}
	NSDictionary* attributes = [object attributesDictionaryForDomainNamed:domain alreadySaved:alreadySaved];
	[item updateAttributes:attributes];
	
	CKDebugLog(@"Updating item <%p> withAttributes:%@",item,attributes);
	return item;
}

- (CKItem*)saveToDomainNamed:(NSString*)domain alreadySaved:(NSMutableSet*)alreadySaved{
	if(_saving || _loading)
		return nil;
	
	_saving = YES;
	CKItem* item = nil;
	if(self.uniqueId == nil){
		self.uniqueId = [NSString stringWithNewUUID];
		[CKModelObject registerObject:self withUniqueId:self.uniqueId];
		item = [CKModelObject createItemWithObject:self inDomainNamed:domain alreadySaved:alreadySaved];
	}
	else{
		item = [CKModelObject itemWithObject:self inDomainNamed:domain];
		if(item != nil){
			item.name = self.modelName;
			NSDictionary* attributes = [self attributesDictionaryForDomainNamed:domain alreadySaved:alreadySaved];
			[item updateAttributes:attributes];
			CKDebugLog(@"Updating item <%p> withAttributes:%@",item,attributes);
		}
		else{
			[CKModelObject registerObject:self withUniqueId:self.uniqueId];
			item = [CKModelObject createItemWithObject:self inDomainNamed:domain];
		}
	}		
	
	[alreadySaved addObject:self];
	_saving = NO;
	return item;
}

+ (CKItem *)createItemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain {
	return [self createItemWithObject:object inDomainNamed:domain alreadySaved:[NSMutableSet set]];
}

- (CKItem*)saveToDomainNamed:(NSString*)domain{
	return [self saveToDomainNamed:domain alreadySaved:[NSMutableSet set]];
}


+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain{
	return [CKModelObject itemWithObject:object inDomainNamed:domain createIfNotFound:NO];
}

+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain createIfNotFound:(BOOL)createIfNotFound{
	CKItem* item = [CKModelObject itemWithUniqueId:object.uniqueId inDomainNamed:domain];
	if(item == nil && createIfNotFound){
		return [object saveToDomainNamed:domain];
	}
	return item;
}

+ (CKItem*)itemWithUniqueId:(NSString*)theUniqueId inDomainNamed:(NSString*)domain{
	CKStore* store = [CKStore storeWithDomainName:domain];
	NSArray *res = [store fetchAttributesWithFormat:[NSString stringWithFormat:@"(name == 'uniqueId' AND value == '%@')",theUniqueId] arguments:nil];
	if([res count] != 1){
		CKDebugLog(@"Warning : %@ object(s) found in domain '%@' with uniqueId '%@'",(([res count]==0) ? @"no" : "Several"),domain,theUniqueId);
		return nil;
	}
	return [[res lastObject]item];	
}

+ (id)releaseObject:(CKWeakRef*)weakRef{
	//CKDebugLog(@"delete object <%p> of type <%@> with id %@",target,[target class],[target uniqueId]);
	[CKModelObjectManager removeObjectForKey:[weakRef.object uniqueId]];
	return nil;
}

+ (CKModelObject*)objectWithUniqueId:(NSString*)uniqueId{
	CKWeakRef* objectRef = [CKModelObjectManager objectForKey:uniqueId];
	id object = [objectRef object];
	if(objectRef != nil){
		//CKDebugLog(@"Found registered object <%p> of type <%@> with uniqueId : %@",object,[object class],uniqueId);
	}
	return object;
}

+ (CKModelObject*)loadObjectWithUniqueId:(NSString*)uniqueId{
	CKModelObject* obj = [self objectWithUniqueId:uniqueId];
	if(obj != nil)
		return obj;
	
	CKStore* store = [CKStore storeWithDomainName:@"whatever"];
	NSArray *res = [store fetchAttributesWithFormat:[NSString stringWithFormat:@"(name == 'uniqueId' AND value == '%@')",uniqueId] arguments:nil];
	if([res count] == 1){
		CKItem* item = (CKItem*)[[res lastObject]item];
		return [NSObject objectFromDictionary:[item propertyListRepresentation]];
	}
	return nil;
}

+ (void)registerObject:(CKModelObject*)object withUniqueId:(NSString*)uniqueId{
	if(uniqueId == nil){
		//CKDebugLog(@"Trying to register an object with no uniqueId : %@",object);
		return;
	}
	
	if(CKModelObjectManager == nil){
		CKModelObjectManager = [[NSMutableDictionary alloc]init];
	}
	
	CKWeakRef* objectRef = [CKWeakRef weakRefWithObject:object target:self action:@selector(releaseObject:)];
	[CKModelObjectManager setObject:objectRef forKey:uniqueId];
	
	//CKDebugLog(@"Register object <%p> of type <%@> with id %@",object,[object class],uniqueId);
}


+ (NSArray*)itemsWithClass:(Class)type withPropertiesAndValues:(NSDictionary*)attributes inDomainNamed:(NSString*)domain{
	CKStore* store = [CKStore storeWithDomainName:domain];
	NSMutableString* predicate = [NSMutableString stringWithFormat:@"(ANY attributes.name == '@class') AND (ANY attributes.value == '%@')",[type description]];
	for(NSString* propertyName in attributes){
		id value = [attributes objectForKey:propertyName];
		NSString* attributeStr = [NSValueTransformer transform:value toClass:[NSString class]];
		[predicate appendFormat:@"AND (ANY attributes.name == '%@') AND (ANY attributes.value == '%@')",propertyName,attributeStr];
	}
	return [store fetchItemsWithPredicateFormat:predicate arguments:nil];
}

@end


@implementation CKModelObject (CKStoreAdditionPrivate)


- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain alreadySaved:(NSMutableSet*)alreadySaved{
	NSAssert(alreadySaved != nil,@"has to be created to avoid recursive save ...");
	NSMutableDictionary* dico = [NSMutableDictionary dictionary];
	
	NSString* className = [[self class] description];
	[dico setObject:className forKey:@"@class"];
	
	NSArray* allProperties = [self allPropertyNames];
	for(NSString* propertyName in allProperties){
		CKObjectProperty* property = [CKObjectProperty propertyWithObject:self keyPath:propertyName];
		CKClassPropertyDescriptor* descriptor = [property descriptor];
		CKModelObjectPropertyMetaData* metaData = [property metaData];
		if( (metaData  && metaData.serializable == NO) || descriptor.isReadOnly == YES){}
		else{
			id propertyValue = [property value];
			if([propertyValue isKindOfClass:[CKDocumentCollection class]]
			   || [propertyValue isKindOfClass:[NSArray class]]
			   || [propertyValue isKindOfClass:[NSSet class]]){
				NSArray* allObjects = propertyValue;
				if([propertyValue isKindOfClass:[NSArray class]] == NO){
					allObjects = [propertyValue allObjects];
				}
				NSMutableArray* result = [NSMutableArray array];
				for(id subObject in allObjects){
					NSAssert([subObject isKindOfClass:[CKModelObject class]],@"Supports only auto serialization on CKModelObject");
					CKModelObject* model = (CKModelObject*)subObject;
					CKItem* item = nil;
					if([alreadySaved containsObject:model] || model.uniqueId != nil){
						item = [CKModelObject itemWithUniqueId:model.uniqueId inDomainNamed:domain];
					}else{
						item = [model saveToDomainNamed:domain alreadySaved:alreadySaved];
					}
					[result addObject:item];
				}
				[dico setObject:result forKey:propertyName];
			}
			else if([propertyValue isKindOfClass:[CKModelObject class]]){
				CKModelObject* model = (CKModelObject*)propertyValue;
				
				NSMutableArray* result = [NSMutableArray array];
				CKItem* item = nil;
				if([alreadySaved containsObject:model] || model.uniqueId != nil){
					item = [CKModelObject itemWithUniqueId:model.uniqueId inDomainNamed:domain];
				}else{
					item = [model saveToDomainNamed:domain alreadySaved:alreadySaved];
				}
				[result addObject:item];
				[dico setObject:result forKey:propertyName];
			}
			else{
				id value = [NSValueTransformer transformProperty:property toClass:[NSString class]];
				if([value isKindOfClass:[NSString class]]){
					[dico setObject:value forKey:propertyName];
				}
			}
		}
	}
	
	return dico;
}

@end