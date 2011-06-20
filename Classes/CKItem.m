//
//  CKItem.m
//
//  Created by Fred Brunel on 10-01-07.
//  Copyright 2010 WhereCloud Inc. All rights reserved.
//

#import "CKItem.h"
#import "CKAttribute.h"
#import "CKAttributesDictionary.h"
#import "CKStore.h"
#import "CKDomain.h"
#import "CKItemAttributeReference.h"

@implementation CKItem

@dynamic name;
@dynamic createdAt;
@dynamic domain;
@dynamic attributes;
@dynamic refAttributes;
@dynamic references;

@end

@implementation CKItem (CKItemsRepresentation)

- (NSDictionary *)propertyListRepresentation {
	return [[[CKAttributesDictionary alloc] initWithItem:self] autorelease];
}

- (NSDictionary *)attributesDictionary {
	return [self propertyListRepresentation];
}

- (NSDictionary *)attributesIndexedByName{
	NSMutableDictionary* dico = [NSMutableDictionary dictionary];
	for(CKAttribute* att in self.attributes){
		[dico setObject:att forKey:att.name];
	}
	return dico;
}

@end


@implementation CKItem (CKItemModification)

- (void)updateAttributes:(NSDictionary*)attributes{
	NSDictionary* indexedAttributes = [self attributesIndexedByName];
	for (id key in [attributes allKeys]) {
		NSAssert([key isKindOfClass:[NSString class]], @"Attribute key must be of class NSString");
		id value = [attributes objectForKey:key];
		if(value != nil){
			CKAttribute* attribute = [self findOrCreateAttributeInDictionary:indexedAttributes withName:key];
			if([value isKindOfClass:[NSString class]]){
				[self updateAttribute:attribute withValue:(NSString*)value];
			}
			else if([value isKindOfClass:[NSArray class]]){
				[self updateAttribute:attribute withItems:(NSArray*)value];
			}
		}
	}
}

- (CKAttribute*)attributeNamed:(NSString*)name createIfNotFound:(BOOL)createIfNotFound{
	CKStore* store = [CKStore storeWithDomainName:self.domain.name];
	BOOL created = NO;
	CKAttribute *attribute = [store fetchAttributeWithPredicate:[NSPredicate predicateWithFormat:@"(item == %@) AND (name == %@)", self,name] 
											   createIfNotFound:createIfNotFound wasCreated:&created];
	if (created) {
		attribute.name = name;
		[self addAttributesObject:attribute];
	}
	return attribute;
}

@end


@implementation CKItem (CKOptimizedItemModification)

- (void)updateAttribute:(CKAttribute*)attribute withValue:(NSString*)value{
	attribute.value = value;
}

- (void)updateAttribute:(CKAttribute*)attribute withItems:(NSArray*)items{
	[attribute removeItemReferences:attribute.itemReferences];
	for(CKItem* item in items){
		CKStore* store = [CKStore storeWithDomainName:self.domain.name];
		CKItemAttributeReference* reference = [store insertNewObjectForEntityForName:@"CKItemAttributeReference"];
		reference.item = item;
		[attribute addItemReferencesObject:reference];
	}
}

- (CKAttribute*)findOrCreateAttributeInDictionary:(NSDictionary*)indexedAttributes withName:(NSString*)name{
	CKAttribute* attribute = [indexedAttributes objectForKey:name];
	if(attribute == nil){
		CKStore* store = [CKStore storeWithDomainName:self.domain.name];
		attribute = [store insertNewObjectForEntityForName:@"CKAttribute"];
		attribute.name = name;
		[self addAttributesObject:attribute];
	}
	return attribute;
}

@end