//
//  CKNSObject+CKStore.m
//  StoreTest
//
//  Created by Sebastien Morel on 11-06-03.
//  Copyright 2011 WhereCloud Inc. All rights reserved.
//

#import "CKModelObject+CKStore.h"
#import "CKStoreDataSource.h"
#import <CloudKit/CKItem.h>
#import <CloudKit/CKStore.h>
#import <CloudKit/CKAttribute.h>
#import <CloudKit/CKDebug.h>
#import <CloudKit/CKModelObject.h>
#import <CloudKit/CKObjectProperty.h>
#import <CloudKit/CKNSValueTransformer+Additions.h>
#import <CloudKit/CKNSStringAdditions.h>


@implementation CKModelObject (CKStoreAddition)

- (NSDictionary*) attributesDictionaryForDomainNamed:(NSString*)domain{
	NSMutableDictionary* dico = [NSMutableDictionary dictionary];
	
	NSString* className = [[self class] description];
	className = [className stringByReplacingOccurrencesOfString:@"_MAZeroingWeakRefSubclass" withString:@""];
	[dico setObject:className forKey:@"@class"];
	
	NSArray* allProperties = [self allPropertyNames];
	for(NSString* propertyName in allProperties){
		CKObjectProperty* property = [CKObjectProperty propertyWithObject:self keyPath:propertyName];
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
				
				CKItem* item = [CKModelObject itemWithObject:model inDomainNamed:domain createIfNotFound:YES];
				[result addObject:item];
			}
			[dico setObject:result forKey:propertyName];
		}
		else{
			id value = [NSValueTransformer transformProperty:property toClass:[NSString class]];
			if(value){
				[dico setObject:value forKey:propertyName];
			}
		}
	}
	
	return dico;
}

+ (CKItem *)createItemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain {
	CKStore* store = [CKStore storeWithDomainName:@"test"];
	BOOL created;
	CKItem *item = [store fetchItemWithPredicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (domain == %@)", object.modelName, domain]
				 createIfNotFound:YES wasCreated:&created];
	if (created) {
		item.name = object.modelName;
		item.domain = store.domain;
		[store.domain addItemsObject:item];
	}
	[item updateAttributes:[object attributesDictionaryForDomainNamed:domain]];
	return item;
}

- (CKItem*)saveToDomainNamed:(NSString*)domain{
	if(_saving)
		return nil;
	
	_saving = YES;
	CKItem* item = nil;
	if(self.uniqueId == nil){
		self.uniqueId = [NSString stringWithNewUUID];
		if(self.modelName == nil){
			self.modelName = self.uniqueId;
		}
		item = [CKModelObject createItemWithObject:self inDomainNamed:domain];
	}
	else{
		item = [CKModelObject itemWithObject:self inDomainNamed:@"test"];
		NSAssert(item != nil,@"item not found");
		item.name = self.modelName;
		[item updateAttributes:[self attributesDictionaryForDomainNamed:domain]];
	}		
	_saving = NO;
	return item;
}

+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain{
	return [CKModelObject itemWithObject:object inDomainNamed:domain createIfNotFound:NO];
}

+ (CKItem*)itemWithObject:(CKModelObject*)object inDomainNamed:(NSString*)domain createIfNotFound:(BOOL)createIfNotFound{
	CKItem* item = [CKModelObject itemWithUniqueId:object.uniqueId inDomainNamed:domain];
	if(item == nil && createIfNotFound){
		return [CKModelObject createItemWithObject:object inDomainNamed:domain];
	}
	return item;
}

+ (CKItem*)itemWithUniqueId:(NSString*)theUniqueId inDomainNamed:(NSString*)domain{
	CKStore* store = [CKStore storeWithDomainName:domain];
	NSArray *res = [store fetchItemsWithPredicateFormat:[NSString stringWithFormat:@"(ANY attributes.name == 'uniqueId') AND (ANY attributes.value == '%@')",theUniqueId] arguments:nil];
	if([res count] != 1){
		CKDebugLog(@"Warning : no object found in domain '%@' with uniqueId '%@'",domain,theUniqueId);
		return nil;
	}
	return [res lastObject];	
}

+ (CKStoreRequest*)requestForObjectsOfType:(Class)type inDomainNamed:(NSString*)domain range:(NSRange)range{
	//TODO
	return nil;
}

@end